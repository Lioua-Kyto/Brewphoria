// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersDataSourceHash() => r'f1c4980e482c9d967683ba88420f37af584697ab';

/// See also [ordersDataSource].
@ProviderFor(ordersDataSource)
final ordersDataSourceProvider =
    AutoDisposeProvider<OrdersRemoteDatasource>.internal(
  ordersDataSource,
  name: r'ordersDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersDataSourceRef = AutoDisposeProviderRef<OrdersRemoteDatasource>;
String _$ordersHash() => r'891a8dac367d41fc8bd6dc2a9c6ad33923e7c5c3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [orders].
@ProviderFor(orders)
const ordersProvider = OrdersFamily();

/// See also [orders].
class OrdersFamily extends Family<AsyncValue<OrdersListResult>> {
  /// See also [orders].
  const OrdersFamily();

  /// See also [orders].
  OrdersProvider call({
    int page = 1,
  }) {
    return OrdersProvider(
      page: page,
    );
  }

  @override
  OrdersProvider getProviderOverride(
    covariant OrdersProvider provider,
  ) {
    return call(
      page: provider.page,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ordersProvider';
}

/// See also [orders].
class OrdersProvider extends AutoDisposeFutureProvider<OrdersListResult> {
  /// See also [orders].
  OrdersProvider({
    int page = 1,
  }) : this._internal(
          (ref) => orders(
            ref as OrdersRef,
            page: page,
          ),
          from: ordersProvider,
          name: r'ordersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$ordersHash,
          dependencies: OrdersFamily._dependencies,
          allTransitiveDependencies: OrdersFamily._allTransitiveDependencies,
          page: page,
        );

  OrdersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
  }) : super.internal();

  final int page;

  @override
  Override overrideWith(
    FutureOr<OrdersListResult> Function(OrdersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrdersProvider._internal(
        (ref) => create(ref as OrdersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<OrdersListResult> createElement() {
    return _OrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersProvider && other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrdersRef on AutoDisposeFutureProviderRef<OrdersListResult> {
  /// The parameter `page` of this provider.
  int get page;
}

class _OrdersProviderElement
    extends AutoDisposeFutureProviderElement<OrdersListResult> with OrdersRef {
  _OrdersProviderElement(super.provider);

  @override
  int get page => (origin as OrdersProvider).page;
}

String _$orderDetailHash() => r'2560bbfa888bc4430be368dd5e2a201956a1d6af';

/// See also [orderDetail].
@ProviderFor(orderDetail)
const orderDetailProvider = OrderDetailFamily();

/// See also [orderDetail].
class OrderDetailFamily extends Family<AsyncValue<OrderModel>> {
  /// See also [orderDetail].
  const OrderDetailFamily();

  /// See also [orderDetail].
  OrderDetailProvider call(
    String orderId,
  ) {
    return OrderDetailProvider(
      orderId,
    );
  }

  @override
  OrderDetailProvider getProviderOverride(
    covariant OrderDetailProvider provider,
  ) {
    return call(
      provider.orderId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderDetailProvider';
}

/// See also [orderDetail].
class OrderDetailProvider extends AutoDisposeFutureProvider<OrderModel> {
  /// See also [orderDetail].
  OrderDetailProvider(
    String orderId,
  ) : this._internal(
          (ref) => orderDetail(
            ref as OrderDetailRef,
            orderId,
          ),
          from: orderDetailProvider,
          name: r'orderDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$orderDetailHash,
          dependencies: OrderDetailFamily._dependencies,
          allTransitiveDependencies:
              OrderDetailFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  OrderDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    FutureOr<OrderModel> Function(OrderDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailProvider._internal(
        (ref) => create(ref as OrderDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<OrderModel> createElement() {
    return _OrderDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderDetailRef on AutoDisposeFutureProviderRef<OrderModel> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailProviderElement
    extends AutoDisposeFutureProviderElement<OrderModel> with OrderDetailRef {
  _OrderDetailProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailProvider).orderId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
