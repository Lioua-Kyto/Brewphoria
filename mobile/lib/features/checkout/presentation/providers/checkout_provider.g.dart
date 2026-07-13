// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderRepositoryHash() => r'e8e96b74f32aac0f560dc97db201f4e59fda9b26';

/// See also [orderRepository].
@ProviderFor(orderRepository)
final orderRepositoryProvider = AutoDisposeProvider<OrderRepository>.internal(
  orderRepository,
  name: r'orderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrderRepositoryRef = AutoDisposeProviderRef<OrderRepository>;
String _$redemptionNotifierHash() =>
    r'fc7a6d17c7e6518b7fdfcc0d051d81b9fd5b2ac7';

/// See also [RedemptionNotifier].
@ProviderFor(RedemptionNotifier)
final redemptionNotifierProvider = AutoDisposeNotifierProvider<
    RedemptionNotifier, AsyncValue<RedemptionValidation?>>.internal(
  RedemptionNotifier.new,
  name: r'redemptionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$redemptionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RedemptionNotifier
    = AutoDisposeNotifier<AsyncValue<RedemptionValidation?>>;
String _$checkoutNotifierHash() => r'6eb3b61fdc0c53a943ccf004e87f2510b574472e';

/// See also [CheckoutNotifier].
@ProviderFor(CheckoutNotifier)
final checkoutNotifierProvider = AutoDisposeNotifierProvider<CheckoutNotifier,
    AsyncValue<OrderModel?>>.internal(
  CheckoutNotifier.new,
  name: r'checkoutNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkoutNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckoutNotifier = AutoDisposeNotifier<AsyncValue<OrderModel?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
