import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';

class WishlistRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  List<ProductModel> _parse(Response<Map<String, dynamic>> res) {
    final data = res.data!['data'] as List<dynamic>;
    return data
        .map((e) => ProductModel.fromJson(
            (e as Map<String, dynamic>)['product'] as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> getWishlist() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>(ApiEndpoints.wishlist);
      return _parse(res);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<ProductModel>> add(String productId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.wishlist,
        data: {'productId': productId},
      );
      return _parse(res);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<ProductModel>> remove(String productId) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>(
          ApiEndpoints.wishlistItem(productId));
      return _parse(res);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
