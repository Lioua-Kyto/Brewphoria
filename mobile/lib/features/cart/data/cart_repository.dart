import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/network/dio_client.dart';
import 'package:coffee_card/core/storage/hive_service.dart';
import 'package:coffee_card/features/cart/data/cart_remote_datasource.dart';
import 'package:coffee_card/features/cart/domain/cart_item_model.dart';
import 'package:coffee_card/features/cart/domain/cart_model.dart';
import 'package:coffee_card/features/shop/domain/modifier_model.dart';
import 'package:coffee_card/features/shop/domain/product_model.dart';

class CartRepository {
  CartRepository(this._datasource);

  final CartRemoteDatasource _datasource;

  CartModel? _loadFromHive() {
    try {
      final json = HiveService.cartBox.get(HiveKeys.cartItems);
      if (json == null) return null;
      return CartModel.fromJson(jsonDecode(json as String) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[CartRepository] loadFromHive error: $e');
      return null;
    }
  }

  Future<void> _saveToHive(CartModel cart) async {
    try {
      await HiveService.cartBox.put(HiveKeys.cartItems, jsonEncode(cart.toJson()));
    } catch (e) {
      debugPrint('[CartRepository] saveToHive error: $e');
    }
  }

  CartModel getLocalCart() => _loadFromHive() ?? const CartModel(id: 'local', items: []);

  Future<CartModel> syncWithBackend() async {
    final cart = await _datasource.getCart();
    await _saveToHive(cart);
    return cart;
  }

  Future<CartModel> addItem(
    String productId,
    int quantity,
    CartModel currentCart, {
    List<String> modifiers = const [],
  }) async {
    // Optimistic update not possible without full product data from Hive
    // so we call backend directly and update Hive with result
    final cart =
        await _datasource.addItem(productId, quantity, modifiers: modifiers);
    await _saveToHive(cart);
    return cart;
  }

  Future<CartModel> updateItem(
    String itemId,
    int quantity,
    CartModel currentCart,
  ) async {
    // Optimistic: update quantity of the matching line
    final optimistic = currentCart.copyWith(
      items: currentCart.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList(),
    );
    await _saveToHive(optimistic);

    try {
      final cart = await _datasource.updateItem(itemId, quantity);
      await _saveToHive(cart);
      return cart;
    } catch (e) {
      // Rollback
      await _saveToHive(currentCart);
      throw e is AppException ? e : mapDioException(e);
    }
  }

  Future<CartModel> removeItem(String itemId, CartModel currentCart) async {
    // Optimistic: remove the matching line
    final optimistic = currentCart.copyWith(
      items: currentCart.items.where((i) => i.id != itemId).toList(),
    );
    await _saveToHive(optimistic);

    try {
      final cart = await _datasource.removeItem(itemId);
      await _saveToHive(cart);
      return cart;
    } catch (e) {
      // Rollback
      await _saveToHive(currentCart);
      throw e is AppException ? e : mapDioException(e);
    }
  }

  Future<void> clearCart() async {
    await HiveService.clearCart();
    try {
      await _datasource.clearCart();
    } catch (e) {
      debugPrint('[CartRepository] clearCart API error: $e');
    }
  }

  // ── Guest (offline) cart ────────────────────────────────────────────────
  // Guests build a purely local cart in Hive; it is pushed to the account on
  // the next sign-in (see [mergeGuestCartToBackend]).

  bool get guestCartPending {
    try {
      return HiveService.userPrefsBox.get(HiveKeys.guestCartPending) == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _setGuestPending(bool value) async {
    try {
      await HiveService.userPrefsBox.put(HiveKeys.guestCartPending, value);
    } catch (_) {}
  }

  /// Resolve selected option ids against the product's groups into stored
  /// modifier snapshots + the effective unit price.
  (List<SelectedModifierModel>, double) _resolveModifiers(
      ProductModel product, List<String> optionIds) {
    final selected = <SelectedModifierModel>[];
    final ids = optionIds.toSet();
    var unit = product.price;
    for (final g in product.modifierGroups) {
      for (final o in g.options) {
        if (ids.contains(o.id)) {
          selected.add(SelectedModifierModel(
            groupId: g.id,
            groupName: g.name,
            optionId: o.id,
            label: o.label,
            priceDelta: o.priceDelta,
          ));
          unit += o.priceDelta;
        }
      }
    }
    return (selected, unit);
  }

  Future<CartModel> addItemLocal(
    ProductModel product,
    int quantity,
    CartModel currentCart, {
    List<String> modifiers = const [],
  }) async {
    final (selected, unit) = _resolveModifiers(product, modifiers);
    // Same product + same option set merges into one line.
    final sortedIds = [...modifiers]..sort();
    final lineId = 'local::${product.id}::${sortedIds.join(',')}';

    final items = [...currentCart.items];
    final idx = items.indexWhere((i) => i.id == lineId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + quantity);
    } else {
      items.add(CartItemModel(
        id: lineId,
        quantity: quantity,
        unitPrice: unit,
        modifiers: selected,
        product: product,
      ));
    }
    final cart = currentCart.copyWith(id: 'local', items: items);
    await _saveToHive(cart);
    await _setGuestPending(true);
    return cart;
  }

  Future<CartModel> updateItemLocal(
      String itemId, int quantity, CartModel currentCart) async {
    final items = currentCart.items
        .map((i) => i.id == itemId ? i.copyWith(quantity: quantity) : i)
        .toList();
    final cart = currentCart.copyWith(items: items);
    await _saveToHive(cart);
    return cart;
  }

  Future<CartModel> removeItemLocal(
      String itemId, CartModel currentCart) async {
    final cart = currentCart.copyWith(
      items: currentCart.items.where((i) => i.id != itemId).toList(),
    );
    await _saveToHive(cart);
    if (cart.items.isEmpty) await _setGuestPending(false);
    return cart;
  }

  Future<void> clearLocalGuestCart() async {
    await HiveService.clearCart();
    await _setGuestPending(false);
  }

  /// Push each locally-built guest line into the account cart, then return the
  /// canonical server cart. Leaves the pending flag set if a push fails so the
  /// merge is retried on the next build.
  Future<CartModel> mergeGuestCartToBackend(CartModel localGuestCart) async {
    for (final item in localGuestCart.items) {
      final optionIds = item.modifiers.map((m) => m.optionId).toList();
      await _datasource.addItem(item.product.id, item.quantity,
          modifiers: optionIds);
    }
    final cart = await syncWithBackend();
    await _setGuestPending(false);
    return cart;
  }
}
