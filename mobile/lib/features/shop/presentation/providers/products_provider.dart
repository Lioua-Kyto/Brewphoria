import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/features/shop/data/product_remote_datasource.dart';
import 'package:brewphoria/features/shop/data/product_repository.dart';
import 'package:brewphoria/features/shop/domain/category_model.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';

part 'products_provider.g.dart';

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ProductRemoteDatasource());
}

@riverpod
Future<List<CategoryModel>> categories(Ref ref) async {
  return ref.read(productRepositoryProvider).getCategories();
}

class ProductFilter {
  const ProductFilter({
    this.page = 1,
    this.limit = 20,
    this.categoryId,
    this.search,
    this.isFeatured,
    this.minPrice,
    this.maxPrice,
    this.sort,
  });

  final int page;
  final int limit;
  final String? categoryId;
  final String? search;
  final bool? isFeatured;
  final double? minPrice;
  final double? maxPrice;
  final String? sort; // newest | price_asc | price_desc | rating

  /// True when any user-facing filter (price / sort) is active — drives the
  /// filter-button "on" indicator.
  bool get hasActiveFilters =>
      minPrice != null || maxPrice != null || (sort != null && sort != 'newest');

  ProductFilter copyWith({
    int? page,
    int? limit,
    String? categoryId,
    String? search,
    bool? isFeatured,
    double? minPrice,
    double? maxPrice,
    String? sort,
    bool clearCategory = false,
    bool clearSearch = false,
    bool clearPrice = false,
    bool clearSort = false,
  }) =>
      ProductFilter(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        search: clearSearch ? null : (search ?? this.search),
        isFeatured: isFeatured ?? this.isFeatured,
        minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
        maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
        sort: clearSort ? null : (sort ?? this.sort),
      );
}

@riverpod
class ProductFilterNotifier extends _$ProductFilterNotifier {
  @override
  ProductFilter build() => const ProductFilter();

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearCategory: categoryId == null, page: 1);
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search, clearSearch: search == null, page: 1);
  }

  /// Applies the sort + price range chosen in the filter sheet.
  void applyRefinements({
    String? sort,
    double? minPrice,
    double? maxPrice,
  }) {
    state = state.copyWith(
      page: 1,
      sort: sort,
      clearSort: sort == null,
      minPrice: minPrice,
      maxPrice: maxPrice,
      clearPrice: minPrice == null && maxPrice == null,
    );
  }

  void nextPage() => state = state.copyWith(page: state.page + 1);
  void reset() => state = const ProductFilter();
}

@riverpod
Future<ProductListResult> products(Ref ref) async {
  final filter = ref.watch(productFilterNotifierProvider);
  return ref.read(productRepositoryProvider).getProducts(
        ProductQueryParams(
          page: filter.page,
          limit: filter.limit,
          category: filter.categoryId,
          search: filter.search,
          isFeatured: filter.isFeatured,
        ),
      );
}

/// Paginated product feed — loads [_pageSize] at a time and appends more as the
/// user scrolls. Rebuilds (and resets to page 1) whenever the category/search
/// filter changes.
const int _pageSize = 10;

@riverpod
class PaginatedProducts extends _$PaginatedProducts {
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loadingMore;

  @override
  Future<List<ProductModel>> build() async {
    final filter = ref.watch(productFilterNotifierProvider);
    _page = 1;
    final result = await ref.read(productRepositoryProvider).getProducts(
          ProductQueryParams(
            page: 1,
            limit: _pageSize,
            category: filter.categoryId,
            search: filter.search,
            minPrice: filter.minPrice,
            maxPrice: filter.maxPrice,
            sort: filter.sort,
          ),
        );
    _hasMore = result.page < result.totalPages;
    return result.products;
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.valueOrNull;
    if (current == null) return;
    _loadingMore = true;
    try {
      final filter = ref.read(productFilterNotifierProvider);
      final result = await ref.read(productRepositoryProvider).getProducts(
            ProductQueryParams(
              page: _page + 1,
              limit: _pageSize,
              category: filter.categoryId,
              search: filter.search,
              minPrice: filter.minPrice,
              maxPrice: filter.maxPrice,
              sort: filter.sort,
            ),
          );
      _page += 1;
      _hasMore = result.page < result.totalPages;
      state = AsyncValue.data([...current, ...result.products]);
    } catch (_) {
      // keep current list; a scroll-triggered failure shouldn't wipe the feed
    } finally {
      _loadingMore = false;
    }
  }
}
