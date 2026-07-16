import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/core/storage/hive_service.dart';
import 'package:brewphoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:brewphoria/features/cart/data/cart_remote_datasource.dart';
import 'package:brewphoria/features/cart/data/cart_repository.dart';
import 'package:brewphoria/features/cart/domain/cart_model.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';

part 'cart_provider.g.dart';

@riverpod
CartRepository cartRepository(Ref ref) {
  return CartRepository(CartRemoteDatasource());
}

/// Selected tip percentage, persisted so it survives restarts.
@riverpod
class CartTip extends _$CartTip {
  @override
  int build() {
    try {
      return (HiveService.userPrefsBox.get(HiveKeys.tipPercent) as int?) ?? 15;
    } catch (_) {
      return 15;
    }
  }

  void set(int percent) {
    state = percent;
    try {
      HiveService.userPrefsBox.put(HiveKeys.tipPercent, percent);
    } catch (_) {}
  }
}

/// Points the shopper has chosen to redeem, shared between the Cart preview and
/// the Checkout slider so the two stay in sync. Reset to 0 after an order.
@riverpod
class CheckoutRedeem extends _$CheckoutRedeem {
  @override
  int build() => 0;

  void set(int points) => state = points;
}

@riverpod
int cartItemCount(Ref ref) {
  final cart = ref.watch(cartNotifierProvider);
  return cart.valueOrNull?.items.fold(0, (sum, item) => (sum ?? 0) + item.quantity) ?? 0;
}

@riverpod
class CartNotifier extends _$CartNotifier {
  bool get _isLoggedIn => ref.read(authNotifierProvider).valueOrNull != null;

  @override
  AsyncValue<CartModel> build() {
    final repo = ref.read(cartRepositoryProvider);
    final localCart = repo.getLocalCart();

    // Merge a guest-built cart into the account the moment we're logged in
    // (covers both the same-session transition and a cold start after login).
    ref.listen(authNotifierProvider, (prev, next) {
      final becameLoggedIn =
          (prev?.valueOrNull == null) && (next.valueOrNull != null);
      if (becameLoggedIn && repo.guestCartPending) _mergeGuestCart();
    });

    if (_isLoggedIn) {
      if (repo.guestCartPending) {
        _mergeGuestCart();
      } else {
        _syncWithBackend();
      }
    }
    return AsyncValue.data(localCart);
  }

  Future<void> _syncWithBackend() async {
    try {
      final cart = await ref.read(cartRepositoryProvider).syncWithBackend();
      state = AsyncValue.data(cart);
    } catch (e, _) {
      // Keep local state, just log
    }
  }

  Future<void> _mergeGuestCart() async {
    final repo = ref.read(cartRepositoryProvider);
    final localGuestCart =
        state.valueOrNull ?? repo.getLocalCart();
    try {
      final cart = await repo.mergeGuestCartToBackend(localGuestCart);
      state = AsyncValue.data(cart);
    } catch (_) {
      // Leave the pending flag set; retried on the next build.
      await _syncWithBackend();
    }
  }

  /// Adds a product to the cart. Logged-in users hit the backend; guests build
  /// a local cart that is merged into their account on sign-in.
  Future<void> addProduct(
    ProductModel product,
    int quantity, {
    List<String> modifiers = const [],
  }) async {
    final previousState = state;
    final repo = ref.read(cartRepositoryProvider);
    final currentCart =
        state.valueOrNull ?? const CartModel(id: 'local', items: []);
    try {
      final cart = _isLoggedIn
          ? await repo.addItem(product.id, quantity, currentCart,
              modifiers: modifiers)
          : await repo.addItemLocal(product, quantity, currentCart,
              modifiers: modifiers);
      state = AsyncValue.data(cart);
    } catch (e, _) {
      state = previousState;
      rethrow;
    }
  }

  /// Backend-only add by product id, for logged-in-only surfaces (order
  /// reorder, in-chat cards) where a full [ProductModel] isn't on hand.
  Future<void> addItem(
    String productId,
    int quantity, {
    List<String> modifiers = const [],
  }) async {
    final previousState = state;
    final currentCart =
        state.valueOrNull ?? const CartModel(id: 'local', items: []);
    try {
      final cart = await ref.read(cartRepositoryProvider).addItem(
            productId,
            quantity,
            currentCart,
            modifiers: modifiers,
          );
      state = AsyncValue.data(cart);
    } catch (e, _) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateItem(String itemId, int quantity) async {
    final previousState = state;
    final repo = ref.read(cartRepositoryProvider);
    final currentCart =
        state.valueOrNull ?? const CartModel(id: 'local', items: []);
    try {
      final cart = _isLoggedIn
          ? await repo.updateItem(itemId, quantity, currentCart)
          : await repo.updateItemLocal(itemId, quantity, currentCart);
      state = AsyncValue.data(cart);
    } catch (e, _) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    final previousState = state;
    final repo = ref.read(cartRepositoryProvider);
    final currentCart =
        state.valueOrNull ?? const CartModel(id: 'local', items: []);
    try {
      final cart = _isLoggedIn
          ? await repo.removeItem(itemId, currentCart)
          : await repo.removeItemLocal(itemId, currentCart);
      state = AsyncValue.data(cart);
    } catch (e, _) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> clearCart() async {
    if (_isLoggedIn) {
      await ref.read(cartRepositoryProvider).clearCart();
    } else {
      await ref.read(cartRepositoryProvider).clearLocalGuestCart();
    }
    state = const AsyncValue.data(CartModel(id: 'local', items: []));
  }

  Future<void> refresh() => _syncWithBackend();
}
