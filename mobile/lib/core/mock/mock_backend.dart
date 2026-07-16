import 'package:brewphoria/core/mock/mock_data.dart';

/// A tiny in-memory backend for offline demo mode. Holds mutable state (cart,
/// orders, wishlist, loyalty, addresses) and answers requests with the same
/// JSON envelopes the real API returns. Driven by [MockInterceptor].
class MockBackend {
  MockBackend._() {
    _seedOrders();
  }
  static final MockBackend instance = MockBackend._();

  // ── Mutable state ──
  final List<Map<String, dynamic>> _cart = [];
  final List<Map<String, dynamic>> _orders = [];
  final Set<String> _wishlist = {'p_1', 'p_15'}; // Cappuccino, Espresso Blend
  final List<Map<String, dynamic>> _addresses =
      mockAddresses.map((a) => Map<String, dynamic>.from(a)).toList();
  final Map<String, dynamic> _user = Map<String, dynamic>.from(mockUser);
  int _currentPoints = mockLoyalty['currentPoints'] as int;
  final List<Map<String, dynamic>> _loyaltyTx = [];
  final List<Map<String, dynamic>> _notifications = [];
  int _seq = 0;

  String _id(String p) => '${p}_${_seq++}';

  // ── Lookups ──
  Map<String, dynamic>? _bySlug(String slug) =>
      mockProducts.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p!['slug'] == slug,
          orElse: () => null);
  Map<String, dynamic>? _byId(String id) =>
      mockProducts.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p!['id'] == id,
          orElse: () => null);

  Map<String, dynamic> _ok(dynamic data,
          [String msg = 'OK', Map<String, dynamic>? meta]) =>
      {
        'success': true,
        'data': data,
        'message': msg,
        if (meta != null) 'meta': meta,
      };

  /// Entry point. Returns (statusCode, envelope).
  (int, Map<String, dynamic>) handle(
    String method,
    String path,
    Map<String, dynamic> query,
    dynamic body,
  ) {
    final segs = path.split('/').where((s) => s.isNotEmpty).toList();
    final b = (body is Map) ? body.cast<String, dynamic>() : <String, dynamic>{};

    // /auth/*
    if (segs.first == 'auth') {
      if (path.endsWith('/login')) {
        return (200, _ok({'user': _user, 'loyaltySummary': _loyalty()}, 'Logged in'));
      }
      return (200, _ok(null, 'OK')); // logout, fcm-token
    }

    // /categories
    if (segs.first == 'categories') return (200, _ok(mockCategories, 'Categories'));

    // /products…
    if (segs.first == 'products') return _products(method, segs, query);

    // /cart…
    if (segs.first == 'cart') return _cartRoutes(method, segs, b);

    // /orders…
    if (segs.first == 'orders') return _orderRoutes(method, segs, b);

    // /loyalty…
    if (segs.first == 'loyalty') return _loyaltyRoutes(method, segs, b);

    // /users/me…
    if (segs.first == 'users') return _userRoutes(method, segs, b);

    // /reviews (create / edit / delete a review)
    if (segs.first == 'reviews') {
      if (method == 'POST') {
        return (201, _ok({
          'id': _id('r'),
          'rating': (b['rating'] as num?)?.toInt() ?? 5,
          'comment': b['comment'] ?? '',
          'images': b['images'] ?? const [],
          'createdAt': DateTime.now().toIso8601String(),
          'user': {
            'displayName': _user['displayName'],
            'avatarUrl': _user['avatarUrl'],
          },
        }, 'Review created'));
      }
      return (200, _ok(null, 'OK'));
    }

    // /notifications…
    if (segs.first == 'notifications') return _notifRoutes(method, segs);

    // /chat/message
    if (segs.first == 'chat') return (200, _ok(_chat(b['message'] as String? ?? '')));

    // /places…
    if (segs.first == 'places') return (200, _ok(<dynamic>[], 'No suggestions'));

    return (200, _ok(null, 'OK'));
  }

  // ── Products ──
  (int, Map<String, dynamic>) _products(
      String method, List<String> segs, Map<String, dynamic> query) {
    // /products/:slug
    if (segs.length == 2) {
      final p = _bySlug(segs[1]);
      if (p == null) return _notFound('PRODUCT');
      final detail = Map<String, dynamic>.from(p)
        ..['modifierGroups'] = mockGroupsForType(p['type'] as String);
      return (200, _ok(detail, 'Product retrieved'));
    }
    // /products/:id/reviews[/summary]
    if (segs.length >= 3 && segs[2] == 'reviews') {
      final p = _byId(segs[1]);
      final slug = p?['slug'] as String? ?? '';
      final reviews =
          reviewsForSlug(slug, (p?['reviewCount'] as int?) ?? 0);
      if (segs.length == 4 && segs[3] == 'summary') {
        return (200, _ok(_reviewSummary(p, reviews)));
      }
      return (200, _ok(reviews, 'Reviews',
          {'page': 1, 'limit': 20, 'total': reviews.length, 'totalPages': 1}));
    }
    // /products (list)
    return (200, _listProducts(query));
  }

  Map<String, dynamic> _listProducts(Map<String, dynamic> q) {
    Iterable<Map<String, dynamic>> items = mockProducts;
    final cat = q['category'] as String?;
    if (cat != null && cat.isNotEmpty) {
      items = items.where((p) => p['categoryId'] == cat);
    }
    final search = (q['search'] as String?)?.toLowerCase();
    if (search != null && search.isNotEmpty) {
      items = items.where((p) =>
          (p['name'] as String).toLowerCase().contains(search) ||
          (p['description'] as String).toLowerCase().contains(search));
    }
    final minP = double.tryParse('${q['minPrice'] ?? ''}');
    final maxP = double.tryParse('${q['maxPrice'] ?? ''}');
    if (minP != null) items = items.where((p) => (p['price'] as num) >= minP);
    if (maxP != null) items = items.where((p) => (p['price'] as num) <= maxP);
    if (q['isFeatured'] == 'true') {
      items = items.where((p) => p['isFeatured'] == true);
    }

    var list = items.toList();
    switch (q['sort']) {
      case 'price_asc':
        list.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
      case 'price_desc':
        list.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
      case 'rating':
        list.sort(
            (a, b) => (b['avgRating'] as num).compareTo(a['avgRating'] as num));
      default: // newest — keep insertion order
    }

    final page = int.tryParse('${q['page'] ?? 1}') ?? 1;
    final limit = int.tryParse('${q['limit'] ?? 20}') ?? 20;
    final total = list.length;
    final start = (page - 1) * limit;
    final pageItems =
        start >= total ? <Map<String, dynamic>>[] : list.skip(start).take(limit).toList();
    return _ok(pageItems, 'Products', {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': (total / limit).ceil().clamp(1, 9999),
    });
  }

  Map<String, dynamic> _reviewSummary(
      Map<String, dynamic>? product, List<dynamic> reviews) {
    final count = (product?['reviewCount'] as int?) ?? reviews.length;
    final avg = (product?['avgRating'] as num?)?.toDouble() ?? 4.6;
    // Weighted distribution that roughly reflects the average.
    final five = (count * 0.68).round();
    final four = (count * 0.2).round();
    final three = (count * 0.07).round();
    final two = (count * 0.03).round();
    final one = (count - five - four - three - two).clamp(0, count);
    return {
      'average': avg,
      'count': count,
      'distribution': {'5': five, '4': four, '3': three, '2': two, '1': one},
    };
  }

  // ── Cart ──
  (List<Map<String, dynamic>>, double) _resolveModifiers(
      Map<String, dynamic> product, List<String> optionIds) {
    final selected = <Map<String, dynamic>>[];
    var unit = (product['price'] as num).toDouble();
    final ids = optionIds.toSet();
    for (final g in mockGroupsForType(product['type'] as String)) {
      for (final o in (g['options'] as List).cast<Map<String, dynamic>>()) {
        if (ids.contains(o['id'])) {
          final delta = (o['priceDelta'] as num).toDouble();
          selected.add({
            'groupId': g['id'],
            'groupName': g['name'],
            'optionId': o['id'],
            'label': o['label'],
            'priceDelta': delta,
          });
          unit += delta;
        }
      }
    }
    return (selected, unit);
  }

  Map<String, dynamic> _cartEnvelope() =>
      _ok({'id': 'cart_demo', 'items': _cart}, 'Cart');

  (int, Map<String, dynamic>) _cartRoutes(
      String method, List<String> segs, Map<String, dynamic> b) {
    // GET /cart
    if (method == 'GET' && segs.length == 1) return (200, _cartEnvelope());
    // DELETE /cart
    if (method == 'DELETE' && segs.length == 1) {
      _cart.clear();
      return (200, _ok(null, 'Cart cleared'));
    }
    // POST /cart/items
    if (method == 'POST' && segs.length == 2) {
      final product = _byId(b['productId'] as String);
      if (product == null) return _notFound('PRODUCT');
      final optionIds = ((b['modifiers'] as List?) ?? const []).cast<String>();
      final (mods, unit) = _resolveModifiers(product, optionIds);
      final qty = (b['quantity'] as num?)?.toInt() ?? 1;
      final key = '${product['id']}::${(optionIds.toList()..sort()).join(',')}';
      final existing = _cart.cast<Map<String, dynamic>?>().firstWhere(
          (i) => i!['_key'] == key,
          orElse: () => null);
      if (existing != null) {
        existing['quantity'] = (existing['quantity'] as int) + qty;
      } else {
        _cart.add({
          'id': _id('ci'),
          '_key': key,
          'quantity': qty,
          'unitPrice': unit,
          'modifiers': mods,
          'product': product,
        });
      }
      return (201, _cartEnvelope());
    }
    // PATCH/DELETE /cart/items/:itemId
    if (segs.length == 3) {
      final itemId = segs[2];
      final idx = _cart.indexWhere((i) => i['id'] == itemId);
      if (idx < 0) return _notFound('CART_ITEM');
      if (method == 'DELETE') {
        _cart.removeAt(idx);
      } else {
        _cart[idx]['quantity'] = (b['quantity'] as num?)?.toInt() ?? 1;
      }
      return (200, _cartEnvelope());
    }
    return (200, _cartEnvelope());
  }

  // ── Orders ──
  (int, Map<String, dynamic>) _orderRoutes(
      String method, List<String> segs, Map<String, dynamic> b) {
    // POST /orders/checkout
    if (method == 'POST' && segs.length == 2 && segs[1] == 'checkout') {
      final order = _checkout(b);
      return (201, _ok(order, 'Order placed successfully'));
    }
    // GET /orders/:id
    if (method == 'GET' && segs.length == 2) {
      final o = _orders.cast<Map<String, dynamic>?>()
          .firstWhere((o) => o!['id'] == segs[1], orElse: () => null);
      return o == null ? _notFound('ORDER') : (200, _ok(o, 'Order'));
    }
    // GET /orders
    return (200, _ok(_orders, 'Orders', {
      'page': 1,
      'limit': 20,
      'total': _orders.length,
      'totalPages': 1,
    }));
  }

  Map<String, dynamic> _checkout(Map<String, dynamic> b) {
    final subtotal = _cart.fold<double>(
        0, (s, i) => s + (i['unitPrice'] as num) * (i['quantity'] as int));
    final delivery = subtotal >= 50 ? 0.0 : 3.99;
    final tip = (b['tip'] as num?)?.toDouble() ?? 0;
    final pointsRedeemed = (b['pointsToRedeem'] as num?)?.toInt() ?? 0;
    final loyaltyDiscount =
        (pointsRedeemed / 100).clamp(0, subtotal).toDouble();
    final total = (subtotal + delivery + tip - loyaltyDiscount)
        .clamp(0, double.infinity)
        .toDouble();
    final pointsEarned = (subtotal * 10 * 1.5).floor(); // GOLD multiplier

    final items = _cart
        .map((i) => {
              'id': _id('oi'),
              'productId': (i['product'] as Map)['id'],
              'productName': (i['product'] as Map)['name'],
              'productImage': ((i['product'] as Map)['images'] as List).first,
              'unitPrice': i['unitPrice'],
              'quantity': i['quantity'],
              'subtotal': (i['unitPrice'] as num) * (i['quantity'] as int),
              'modifiers': i['modifiers'],
            })
        .toList();

    final addr = _addresses.cast<Map<String, dynamic>?>().firstWhere(
        (a) => a!['id'] == b['addressId'],
        orElse: () => _addresses.isNotEmpty ? _addresses.first : null);

    final order = {
      'id': _id('order'),
      'status': 'CONFIRMED',
      'subtotal': subtotal,
      'deliveryFee': delivery,
      'discount': 0,
      'tip': tip,
      'loyaltyDiscount': loyaltyDiscount,
      'total': total,
      'pointsEarned': pointsEarned,
      'pointsRedeemed': pointsRedeemed,
      'paymentMethod': (b['paymentMethod'] as String?) ?? 'COD',
      'notes': b['notes'],
      'estimatedReadyAt':
          DateTime.now().add(const Duration(minutes: 11)).toIso8601String(),
      'items': items,
      'address': addr == null ? null : _orderAddress(addr),
      'createdAt': DateTime.now().toIso8601String(),
    };

    _orders.insert(0, order);
    _currentPoints = (_currentPoints + pointsEarned - pointsRedeemed).clamp(0, 999999);
    _cart.clear();
    return order;
  }

  Map<String, dynamic> _orderAddress(Map<String, dynamic> a) => {
        'fullName': a['fullName'],
        'phone': a['phone'],
        'street': a['street'],
        'city': a['city'],
        'state': a['state'],
        'postalCode': a['postalCode'],
        'country': a['country'],
        'label': a['label'],
      };

  void _seedOrders() {
    Map<String, dynamic> item(String slug, int qty) {
      final p = _bySlug(slug)!;
      return {
        'id': _id('oi'),
        'productId': p['id'],
        'productName': p['name'],
        'productImage': (p['images'] as List).first,
        'unitPrice': p['price'],
        'quantity': qty,
        'subtotal': (p['price'] as num) * qty,
        'modifiers': const [],
        'hasReview': false,
      };
    }

    Map<String, dynamic> order(String id, String status, int daysAgo,
        List<Map<String, dynamic>> items) {
      final subtotal =
          items.fold<double>(0, (s, i) => s + (i['subtotal'] as num));
      return {
        'id': id,
        'status': status,
        'subtotal': subtotal,
        'deliveryFee': 0,
        'discount': 0,
        'tip': 2.0,
        'loyaltyDiscount': 0,
        'total': subtotal + 2.0,
        'pointsEarned': (subtotal * 10 * 1.5).floor(),
        'pointsRedeemed': 0,
        'paymentMethod': 'COD',
        'estimatedReadyAt': null,
        'items': items,
        'address': _orderAddress(_addresses.first),
        'createdAt': DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String(),
      };
    }

    _orders.addAll([
      order('order_seed_1', 'DELIVERED', 3, [item('cappuccino', 1), item('butter-croissant', 2)]),
      order('order_seed_2', 'DELIVERED', 9, [item('iced-matcha-latte', 1)]),
      order('order_seed_3', 'DELIVERED', 21, [item('espresso-blend-1kg', 1)]),
    ]);
  }

  // ── Loyalty ──
  Map<String, dynamic> _loyalty() => {
        'id': 'l_demo',
        'currentPoints': _currentPoints,
        'lifetimePoints': mockLoyalty['lifetimePoints'],
        'tier': mockLoyalty['tier'],
      };

  (int, Map<String, dynamic>) _loyaltyRoutes(
      String method, List<String> segs, Map<String, dynamic> b) {
    if (segs.length == 2 && segs[1] == 'history') {
      final tx = _loyaltyTx.isNotEmpty
          ? _loyaltyTx
          : [
              {'id': 't1', 'type': 'EARNED', 'points': 68, 'description': 'Order #A12F', 'createdAt': _isoDays(3)},
              {'id': 't2', 'type': 'EARNED', 'points': 90, 'description': 'Order #9C4D', 'createdAt': _isoDays(9)},
              {'id': 't3', 'type': 'BONUS', 'points': 250, 'description': 'Welcome bonus', 'createdAt': _isoDays(30)},
              {'id': 't4', 'type': 'REDEEMED', 'points': -300, 'description': 'Redeemed \$3 credit', 'createdAt': _isoDays(45)},
            ];
      return (200, _ok(tx, 'History',
          {'page': 1, 'limit': 20, 'total': tx.length, 'totalPages': 1}));
    }
    if (method == 'POST' && segs.length == 2 && segs[1] == 'redeem') {
      final pts = (b['points'] as num?)?.toInt() ?? 0;
      return (200, _ok({
        'pointsToRedeem': pts,
        'discountAmount': pts / 100,
        'remainingPoints': (_currentPoints - pts).clamp(0, 999999),
      }));
    }
    return (200, _ok(_loyalty(), 'Loyalty'));
  }

  String _isoDays(int d) =>
      DateTime.now().subtract(Duration(days: d)).toIso8601String();

  // ── Users / wishlist / addresses ──
  (int, Map<String, dynamic>) _userRoutes(
      String method, List<String> segs, Map<String, dynamic> b) {
    // /users/me
    if (segs.length == 2) {
      if (method == 'PATCH') {
        if (b['displayName'] != null) {
          final name = (b['displayName'] as String).trim();
          _user['displayName'] = name;
          final parts = name.split(RegExp(r'\s+'));
          _user['firstName'] = parts.isNotEmpty ? parts.first : null;
          _user['lastName'] = parts.length > 1 ? parts.sublist(1).join(' ') : null;
        }
        if (b['avatarUrl'] != null) _user['avatarUrl'] = b['avatarUrl'];
      }
      return (200, _ok(_user, 'Profile'));
    }
    // /users/me/addresses…
    if (segs.length >= 3 && segs[2] == 'addresses') {
      if (method == 'POST') {
        final a = Map<String, dynamic>.from(b)..['id'] = _id('addr');
        if (a['isDefault'] == true) {
          for (final x in _addresses) {
            x['isDefault'] = false;
          }
        }
        _addresses.add(a);
        return (201, _ok(a, 'Address added'));
      }
      if (segs.length == 4) {
        final id = segs[3];
        final idx = _addresses.indexWhere((a) => a['id'] == id);
        if (method == 'DELETE') {
          if (idx >= 0) _addresses.removeAt(idx);
          return (200, _ok(null, 'Address deleted'));
        }
        if (method == 'PATCH' && idx >= 0) {
          _addresses[idx].addAll(b);
          return (200, _ok(_addresses[idx], 'Address updated'));
        }
      }
      return (200, _ok(_addresses, 'Addresses'));
    }
    // /users/me/wishlist…
    if (segs.length >= 3 && segs[2] == 'wishlist') {
      if (method == 'POST') {
        _wishlist.add(b['productId'] as String);
        return (201, _ok({'id': _id('w'), 'productId': b['productId']}, 'Added'));
      }
      if (method == 'DELETE' && segs.length == 4) {
        _wishlist.remove(segs[3]);
        return (200, _ok(null, 'Removed from wishlist'));
      }
      final products =
          mockProducts.where((p) => _wishlist.contains(p['id'])).toList();
      return (200, _ok(products, 'Wishlist'));
    }
    return (200, _ok(_user, 'Profile'));
  }

  // ── Notifications ──
  (int, Map<String, dynamic>) _notifRoutes(String method, List<String> segs) {
    if (method == 'PATCH') {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
      return (200, _ok(null, 'Marked read'));
    }
    if (_notifications.isEmpty) {
      _notifications.addAll([
        {'id': 'n1', 'type': 'LOYALTY_TIER_UP', 'title': 'You reached Gold! ☕', 'body': "You're now earning 1.5× points on every order.", 'data': {}, 'isRead': false, 'createdAt': _isoDays(2)},
        {'id': 'n2', 'type': 'ORDER_STATUS_CHANGED', 'title': 'Order delivered', 'body': 'Your cappuccino & croissants were delivered. Enjoy!', 'data': {'orderId': 'order_seed_1'}, 'isRead': true, 'createdAt': _isoDays(3)},
        {'id': 'n3', 'type': 'NEW_SALE', 'title': 'Weekend treat', 'body': 'Free oat-milk upgrade on any iced drink this weekend.', 'data': {}, 'isRead': true, 'createdAt': _isoDays(5)},
      ]);
    }
    return (200, _ok(_notifications, 'Notifications',
        {'page': 1, 'limit': 20, 'total': _notifications.length, 'totalPages': 1}));
  }

  // ── Chat (canned barista) ──
  Map<String, dynamic> _chat(String message) {
    final m = message.toLowerCase();
    // Try to reference a real product the user mentions or a sensible default.
    Map<String, dynamic>? match;
    for (final p in mockProducts) {
      if (m.contains((p['name'] as String).toLowerCase())) {
        match = p;
        break;
      }
    }
    match ??= m.contains('iced') || m.contains('cold')
        ? _bySlug('iced-matcha-latte')
        : m.contains('bean') || m.contains('brew at home')
            ? _bySlug('ethiopian-yirgacheffe-250g')
            : _bySlug('cappuccino');

    final reply = match == null
        ? "I'd love to help you find the perfect brew! Tell me if you're after something hot, iced, or a bag of beans for home."
        : "Great choice! Our ${match['name']} is a customer favourite — "
            "${(match['description'] as String)} It's \$${(match['price'] as num).toStringAsFixed(2)} "
            "and rated ${(match['avgRating'] as num).toStringAsFixed(1)}/5. Want me to add it to your cart?";

    return {
      'sessionId': 'mock-session',
      'reply': reply,
      if (match != null)
        'product': {
          'id': match['id'],
          'slug': match['slug'],
          'name': match['name'],
          'image': (match['images'] as List).first,
          'price': match['price'],
          'meta': match['type'] == 'DRINK' ? 'Customisable' : null,
        },
    };
  }

  (int, Map<String, dynamic>) _notFound(String resource) =>
      (404, {
        'success': false,
        'error': {'code': '${resource}_NOT_FOUND', 'message': '$resource not found'},
      });
}
