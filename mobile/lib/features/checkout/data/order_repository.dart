import 'package:dio/dio.dart';
import 'package:coffee_card/core/constants/api_endpoints.dart';
import 'package:coffee_card/core/network/dio_client.dart';
import 'package:coffee_card/features/orders/domain/order_history_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<OrderModel> checkout(CheckoutRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.checkout,
        data: {
          'addressId': request.addressId,
          'pointsToRedeem': request.pointsToRedeem,
          'paymentMethod': request.paymentMethod,
          'tip': request.tip,
          if (request.notes != null) 'notes': request.notes,
        },
      );
      return OrderModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
