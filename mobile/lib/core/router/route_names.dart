abstract final class RouteNames {
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String shop = 'shop';
  static const String productDetail = 'product-detail';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String checkoutSuccess = 'checkout-success';
  static const String orders = 'orders';
  static const String orderDetail = 'order-detail';
  static const String loyalty = 'loyalty';
  static const String notifications = 'notifications';
  static const String profile = 'profile';
  static const String addresses = 'addresses';
  static const String chat = 'chat';
  static const String writeReview = 'write-review';
  static const String reviews = 'product-reviews';
}

abstract final class RoutePaths {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String shop = '/shop';
  static const String productDetail = '/shop/:slug';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout/success';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String loyalty = '/loyalty';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String addresses = '/profile/addresses';
  static const String chat = '/chat';
  static const String writeReview = '/reviews/write/:orderId';
  static const String reviews = '/reviews/product/:id';
}
