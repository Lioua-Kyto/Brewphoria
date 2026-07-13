// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wishlistIdsHash() => r'26ef80eae74f082123ec5719a5ea804f0523117c';

/// See also [wishlistIds].
@ProviderFor(wishlistIds)
final wishlistIdsProvider = AutoDisposeProvider<Set<String>>.internal(
  wishlistIds,
  name: r'wishlistIdsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$wishlistIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistIdsRef = AutoDisposeProviderRef<Set<String>>;
String _$wishlistNotifierHash() => r'fcc53c555406817e9d8a7c460d82d41536509d3b';

/// See also [WishlistNotifier].
@ProviderFor(WishlistNotifier)
final wishlistNotifierProvider = AutoDisposeAsyncNotifierProvider<
    WishlistNotifier, List<ProductModel>>.internal(
  WishlistNotifier.new,
  name: r'wishlistNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WishlistNotifier = AutoDisposeAsyncNotifier<List<ProductModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
