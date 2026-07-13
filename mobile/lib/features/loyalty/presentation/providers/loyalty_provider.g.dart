// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loyaltyDataSourceHash() => r'c4ac93900d5ebd8fb3f12bd8ce6a9e643fe0c446';

/// See also [loyaltyDataSource].
@ProviderFor(loyaltyDataSource)
final loyaltyDataSourceProvider =
    AutoDisposeProvider<LoyaltyRemoteDatasource>.internal(
  loyaltyDataSource,
  name: r'loyaltyDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loyaltyDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoyaltyDataSourceRef = AutoDisposeProviderRef<LoyaltyRemoteDatasource>;
String _$loyaltyAccountHash() => r'b9ab73c337f93cd6f786bf160d324aa83b7b7834';

/// See also [loyaltyAccount].
@ProviderFor(loyaltyAccount)
final loyaltyAccountProvider = AutoDisposeFutureProvider<LoyaltyModel>.internal(
  loyaltyAccount,
  name: r'loyaltyAccountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loyaltyAccountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoyaltyAccountRef = AutoDisposeFutureProviderRef<LoyaltyModel>;
String _$loyaltyHistoryHash() => r'b0abd95e0ebdd772367213c3c10f49467a25988c';

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

/// See also [loyaltyHistory].
@ProviderFor(loyaltyHistory)
const loyaltyHistoryProvider = LoyaltyHistoryFamily();

/// See also [loyaltyHistory].
class LoyaltyHistoryFamily
    extends Family<AsyncValue<LoyaltyTransactionsResult>> {
  /// See also [loyaltyHistory].
  const LoyaltyHistoryFamily();

  /// See also [loyaltyHistory].
  LoyaltyHistoryProvider call({
    int page = 1,
  }) {
    return LoyaltyHistoryProvider(
      page: page,
    );
  }

  @override
  LoyaltyHistoryProvider getProviderOverride(
    covariant LoyaltyHistoryProvider provider,
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
  String? get name => r'loyaltyHistoryProvider';
}

/// See also [loyaltyHistory].
class LoyaltyHistoryProvider
    extends AutoDisposeFutureProvider<LoyaltyTransactionsResult> {
  /// See also [loyaltyHistory].
  LoyaltyHistoryProvider({
    int page = 1,
  }) : this._internal(
          (ref) => loyaltyHistory(
            ref as LoyaltyHistoryRef,
            page: page,
          ),
          from: loyaltyHistoryProvider,
          name: r'loyaltyHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loyaltyHistoryHash,
          dependencies: LoyaltyHistoryFamily._dependencies,
          allTransitiveDependencies:
              LoyaltyHistoryFamily._allTransitiveDependencies,
          page: page,
        );

  LoyaltyHistoryProvider._internal(
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
    FutureOr<LoyaltyTransactionsResult> Function(LoyaltyHistoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LoyaltyHistoryProvider._internal(
        (ref) => create(ref as LoyaltyHistoryRef),
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
  AutoDisposeFutureProviderElement<LoyaltyTransactionsResult> createElement() {
    return _LoyaltyHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoyaltyHistoryProvider && other.page == page;
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
mixin LoyaltyHistoryRef
    on AutoDisposeFutureProviderRef<LoyaltyTransactionsResult> {
  /// The parameter `page` of this provider.
  int get page;
}

class _LoyaltyHistoryProviderElement
    extends AutoDisposeFutureProviderElement<LoyaltyTransactionsResult>
    with LoyaltyHistoryRef {
  _LoyaltyHistoryProviderElement(super.provider);

  @override
  int get page => (origin as LoyaltyHistoryProvider).page;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
