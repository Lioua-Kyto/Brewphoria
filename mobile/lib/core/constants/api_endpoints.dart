abstract final class ApiEndpoints {
  // Base URLs
  static const String _androidBase = 'http://10.0.2.2:3000/api/v1';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _androidBase,
  );

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String fcmToken = '/auth/fcm-token';

  // Users
  static const String me = '/users/me';
  static const String addresses = '/users/me/addresses';
  static String addressById(String id) => '/users/me/addresses/$id';

  // Wishlist
  static const String wishlist = '/users/me/wishlist';
  static String wishlistItem(String productId) =>
      '/users/me/wishlist/$productId';

  // Categories
  static const String categories = '/categories';

  // Products
  static const String products = '/products';
  static String productBySlug(String slug) => '/products/$slug';
  static String productReviews(String id) => '/products/$id/reviews';
  static String productReviewSummary(String id) =>
      '/products/$id/reviews/summary';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String itemId) => '/cart/items/$itemId';

  // Orders
  static const String checkout = '/orders/checkout';
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // Reviews
  static const String reviews = '/reviews';
  static String reviewById(String id) => '/reviews/$id';

  // Loyalty
  static const String loyalty = '/loyalty';
  static const String loyaltyHistory = '/loyalty/history';
  static const String loyaltyRedeem = '/loyalty/redeem';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';

  // Chat
  static const String chatMessage = '/chat/message';

  // Places (address autocomplete proxy)
  static const String placesAutocomplete = '/places/autocomplete';
  static String placeDetails(String placeId) => '/places/details/$placeId';
}
