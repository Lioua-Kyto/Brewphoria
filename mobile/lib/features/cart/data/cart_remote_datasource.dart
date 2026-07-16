import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';
import 'package:brewphoria/features/cart/domain/cart_model.dart';

class CartRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<CartModel> getCart() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.cart);
      return CartModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<CartModel> addItem(
    String productId,
    int quantity, {
    List<String> modifiers = const [],
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.cartItems,
        data: {
          'productId': productId,
          'quantity': quantity,
          'modifiers': modifiers,
        },
      );
      return CartModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<CartModel> updateItem(String itemId, int quantity) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.cartItem(itemId),
        data: {'quantity': quantity},
      );
      return CartModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<CartModel> removeItem(String itemId) async {
    try {
      final response =
          await _dio.delete<Map<String, dynamic>>(ApiEndpoints.cartItem(itemId));
      return CartModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete<void>(ApiEndpoints.cart);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
