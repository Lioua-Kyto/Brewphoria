// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartRepositoryHash() => r'2ea4e4c057866807f165b63a3b9a4da89a26bae6';

/// See also [cartRepository].
@ProviderFor(cartRepository)
final cartRepositoryProvider = AutoDisposeProvider<CartRepository>.internal(
  cartRepository,
  name: r'cartRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartRepositoryRef = AutoDisposeProviderRef<CartRepository>;
String _$cartItemCountHash() => r'b105bdcc9b3cbe99900382cbdf98258577d42538';

/// See also [cartItemCount].
@ProviderFor(cartItemCount)
final cartItemCountProvider = AutoDisposeProvider<int>.internal(
  cartItemCount,
  name: r'cartItemCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartItemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartItemCountRef = AutoDisposeProviderRef<int>;
String _$cartTipHash() => r'51bc0bfe8f89024d075dcce50305918fb196c983';

/// Selected tip percentage, persisted so it survives restarts.
///
/// Copied from [CartTip].
@ProviderFor(CartTip)
final cartTipProvider = AutoDisposeNotifierProvider<CartTip, int>.internal(
  CartTip.new,
  name: r'cartTipProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartTipHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartTip = AutoDisposeNotifier<int>;
String _$checkoutRedeemHash() => r'7f84a8efc8ca113502f9505afcf6f8b916fae976';

/// Points the shopper has chosen to redeem, shared between the Cart preview and
/// the Checkout slider so the two stay in sync. Reset to 0 after an order.
///
/// Copied from [CheckoutRedeem].
@ProviderFor(CheckoutRedeem)
final checkoutRedeemProvider =
    AutoDisposeNotifierProvider<CheckoutRedeem, int>.internal(
  CheckoutRedeem.new,
  name: r'checkoutRedeemProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkoutRedeemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckoutRedeem = AutoDisposeNotifier<int>;
String _$cartNotifierHash() => r'ab9fd32b6bf65775af4808af8cf4b345f307884b';

/// See also [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider =
    AutoDisposeNotifierProvider<CartNotifier, AsyncValue<CartModel>>.internal(
  CartNotifier.new,
  name: r'cartNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartNotifier = AutoDisposeNotifier<AsyncValue<CartModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
