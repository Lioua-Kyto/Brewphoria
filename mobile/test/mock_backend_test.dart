import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_card/core/mock/mock_backend.dart';
import 'package:coffee_card/features/shop/domain/product_model.dart';
import 'package:coffee_card/features/shop/domain/category_model.dart';
import 'package:coffee_card/features/reviews/domain/review_model.dart';
import 'package:coffee_card/features/cart/domain/cart_model.dart';
import 'package:coffee_card/features/checkout/domain/order_model.dart';
import 'package:coffee_card/features/loyalty/domain/loyalty_model.dart';
import 'package:coffee_card/features/auth/domain/user_model.dart';

/// Validates that the offline mock backend produces JSON that the real domain
/// models can actually parse — the whole point of the Dio-interceptor approach.
void main() {
  final backend = MockBackend.instance;

  Map<String, dynamic> get(String path,
      [Map<String, dynamic> q = const {}]) {
    final (status, body) = backend.handle('GET', path, q, null);
    expect(status, lessThan(400), reason: 'GET $path -> $status');
    return body;
  }

  test('products list parses + honours pagination/sort', () {
    final body = get('/products', {'page': '1', 'limit': '10', 'sort': 'price_asc'});
    final data = (body['data'] as List).cast<Map<String, dynamic>>();
    expect(data.length, 10);
    final products = data.map(ProductModel.fromJson).toList();
    expect(products.first.name, isNotEmpty);
    // price_asc → ascending
    expect(products.first.price, lessThanOrEqualTo(products.last.price));
    expect(body['meta']['total'], greaterThan(20));
  });

  test('categories parse', () {
    final data = (get('/categories')['data'] as List).cast<Map<String, dynamic>>();
    final cats = data.map(CategoryModel.fromJson).toList();
    expect(cats.length, 6);
  });

  test('product detail gates modifier groups by type', () {
    final drink = ProductModel.fromJson(
        get('/products/cappuccino')['data'] as Map<String, dynamic>);
    expect(drink.type, 'DRINK');
    expect(drink.modifierGroups.map((g) => g.name),
        containsAll(['Size', 'Milk', 'Sweetness', 'Add-ons']));

    final beans = ProductModel.fromJson(
        get('/products/espresso-blend-1kg')['data'] as Map<String, dynamic>);
    expect(beans.type, 'BEANS');
    expect(beans.modifierGroups.single.name, 'Grind');

    final merch = ProductModel.fromJson(
        get('/products/brewphoria-tote-bag')['data'] as Map<String, dynamic>);
    expect(merch.type, 'MERCH');
    expect(merch.modifierGroups, isEmpty);
    expect(merch.roastLevel, isNull);
  });

  test('reviews + summary parse (by product id)', () {
    final capp = ProductModel.fromJson(
        get('/products/cappuccino')['data'] as Map<String, dynamic>);
    final reviews = (get('/products/${capp.id}/reviews')['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .toList();
    expect(reviews, isNotEmpty);
    expect(reviews.first.user?.displayName, isNotEmpty);

    final summary = get('/products/${capp.id}/reviews/summary')['data']
        as Map<String, dynamic>;
    expect(summary['count'], greaterThan(0));
    expect((summary['distribution'] as Map).length, 5);
  });

  test('cart add/update/remove parses through CartModel', () {
    // fresh
    backend.handle('DELETE', '/cart', const {}, null);
    final capp = ProductModel.fromJson(
        get('/products/cappuccino')['data'] as Map<String, dynamic>);
    final (_, addBody) = backend.handle('POST', '/cart/items', const {},
        {'productId': capp.id, 'quantity': 2, 'modifiers': ['o_lg', 'o_oat']});
    final cart = CartModel.fromJson(addBody['data'] as Map<String, dynamic>);
    expect(cart.items.length, 1);
    final line = cart.items.first;
    // base 4.50 + Large 0.6 + Oat 0.6 = 5.70
    expect(line.unitPrice, closeTo(5.70, 0.001));
    expect(line.modifiers.map((m) => m.label), containsAll(['Large', 'Oat']));

    // update qty
    final (_, upd) = backend.handle(
        'PATCH', '/cart/items/${line.id}', const {}, {'quantity': 3});
    expect(CartModel.fromJson(upd['data'] as Map<String, dynamic>).items.first.quantity, 3);

    // remove
    final (_, rem) = backend.handle('DELETE', '/cart/items/${line.id}', const {}, null);
    expect(CartModel.fromJson(rem['data'] as Map<String, dynamic>).items, isEmpty);
  });

  test('checkout parses through OrderModel + orders list', () {
    backend.handle('DELETE', '/cart', const {}, null);
    final capp = ProductModel.fromJson(
        get('/products/cappuccino')['data'] as Map<String, dynamic>);
    backend.handle('POST', '/cart/items', const {},
        {'productId': capp.id, 'quantity': 1, 'modifiers': <String>[]});
    final (status, body) = backend.handle('POST', '/orders/checkout', const {},
        {'addressId': 'a_home', 'tip': 2.0, 'pointsToRedeem': 0});
    expect(status, 201);
    final order = OrderModel.fromJson(body['data'] as Map<String, dynamic>);
    expect(order.status, 'CONFIRMED');
    expect(order.items, isNotEmpty);
    expect(order.estimatedReadyAt, isNotNull);

    final orders = (get('/orders')['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
    expect(orders.length, greaterThanOrEqualTo(4)); // 3 seeded + 1 new
  });

  test('loyalty + history + wishlist + user parse', () {
    LoyaltyModel.fromJson(get('/loyalty')['data'] as Map<String, dynamic>);
    final history = (get('/loyalty/history')['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(LoyaltyTransactionModel.fromJson)
        .toList();
    expect(history, isNotEmpty);

    final wl = (get('/users/me/wishlist')['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
    expect(wl, isNotEmpty);

    UserModel.fromJson(get('/users/me')['data'] as Map<String, dynamic>);
  });
}
