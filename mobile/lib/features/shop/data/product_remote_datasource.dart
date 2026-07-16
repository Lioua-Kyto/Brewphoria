import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';
import 'package:brewphoria/features/shop/domain/category_model.dart';

class ProductQueryParams {
  const ProductQueryParams({
    this.page = 1,
    this.limit = 20,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.isFeatured,
    this.search,
    this.sort,
  });

  final int page;
  final int limit;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? isFeatured;
  final String? search;
  final String? sort;

  Map<String, dynamic> toQueryMap() => {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
        if (search != null && search!.isNotEmpty) 'search': search,
        if (sort != null) 'sort': sort,
      };
}

class ProductListResult {
  const ProductListResult({
    required this.products,
    required this.total,
    required this.totalPages,
    required this.page,
  });

  final List<ProductModel> products;
  final int total;
  final int totalPages;
  final int page;
}

class ProductRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.categories);
      final data = response.data!['data'] as List<dynamic>;
      return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ProductListResult> getProducts(ProductQueryParams params) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.products,
        queryParameters: params.toQueryMap(),
      );
      final data = response.data!['data'] as List<dynamic>;
      final meta = response.data!['meta'] as Map<String, dynamic>?;
      return ProductListResult(
        products: data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
        total: (meta?['total'] as int?) ?? 0,
        totalPages: (meta?['totalPages'] as int?) ?? 1,
        page: (meta?['page'] as int?) ?? 1,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ProductModel> getProductBySlug(String slug) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiEndpoints.productBySlug(slug));
      return ProductModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<dynamic>> getProductReviews(String productId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.productReviews(productId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data!['data'] as List<dynamic>;
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
