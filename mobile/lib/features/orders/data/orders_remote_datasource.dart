import 'package:dio/dio.dart';
import 'package:coffee_card/core/constants/api_endpoints.dart';
import 'package:coffee_card/core/network/dio_client.dart';
import 'package:coffee_card/features/checkout/domain/order_model.dart';

class OrdersListResult {
  const OrdersListResult({
    required this.orders,
    required this.total,
    required this.totalPages,
    required this.page,
  });

  final List<OrderModel> orders;
  final int total;
  final int totalPages;
  final int page;
}

class OrdersRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<OrdersListResult> getOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orders,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data!['data'] as List<dynamic>;
      final meta = response.data!['meta'] as Map<String, dynamic>?;
      return OrdersListResult(
        orders: data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList(),
        total: (meta?['total'] as int?) ?? 0,
        totalPages: (meta?['totalPages'] as int?) ?? 1,
        page: (meta?['page'] as int?) ?? 1,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiEndpoints.orderById(id));
      return OrderModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
