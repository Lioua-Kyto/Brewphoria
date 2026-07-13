// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRepositoryHash() => r'1df21202edef37969d8a40c0e4c3bb3d71ddc7ac';

/// See also [productRepository].
@ProviderFor(productRepository)
final productRepositoryProvider =
    AutoDisposeProvider<ProductRepository>.internal(
  productRepository,
  name: r'productRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductRepositoryRef = AutoDisposeProviderRef<ProductRepository>;
String _$categoriesHash() => r'5357f1d45ac55803d3ad89d20b5a193ea1abf9e9';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider =
    AutoDisposeFutureProvider<List<CategoryModel>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRef = AutoDisposeFutureProviderRef<List<CategoryModel>>;
String _$productsHash() => r'5d21894d2e055cf67ffdf89ddbda7e75c458a58e';

/// See also [products].
@ProviderFor(products)
final productsProvider = AutoDisposeFutureProvider<ProductListResult>.internal(
  products,
  name: r'productsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$productsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsRef = AutoDisposeFutureProviderRef<ProductListResult>;
String _$productFilterNotifierHash() =>
    r'6bf9a2071917a8845ec431d4666824c985aaf05a';

/// See also [ProductFilterNotifier].
@ProviderFor(ProductFilterNotifier)
final productFilterNotifierProvider =
    AutoDisposeNotifierProvider<ProductFilterNotifier, ProductFilter>.internal(
  ProductFilterNotifier.new,
  name: r'productFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductFilterNotifier = AutoDisposeNotifier<ProductFilter>;
String _$paginatedProductsHash() => r'bc4c65b213c8592c39c5e66d7e49bed6dc825933';

/// See also [PaginatedProducts].
@ProviderFor(PaginatedProducts)
final paginatedProductsProvider = AutoDisposeAsyncNotifierProvider<
    PaginatedProducts, List<ProductModel>>.internal(
  PaginatedProducts.new,
  name: r'paginatedProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paginatedProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaginatedProducts = AutoDisposeAsyncNotifier<List<ProductModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
