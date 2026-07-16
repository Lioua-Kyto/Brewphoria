import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';
import 'package:brewphoria/features/loyalty/domain/loyalty_model.dart';

class LoyaltyTransactionsResult {
  const LoyaltyTransactionsResult({
    required this.transactions,
    required this.total,
    required this.totalPages,
    required this.page,
  });

  final List<LoyaltyTransactionModel> transactions;
  final int total;
  final int totalPages;
  final int page;
}

class LoyaltyRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<LoyaltyModel> getLoyaltyAccount() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.loyalty);
      return LoyaltyModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<LoyaltyTransactionsResult> getHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.loyaltyHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data!['data'] as List<dynamic>;
      final meta = response.data!['meta'] as Map<String, dynamic>?;
      return LoyaltyTransactionsResult(
        transactions: data
            .map((e) => LoyaltyTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (meta?['total'] as int?) ?? 0,
        totalPages: (meta?['totalPages'] as int?) ?? 1,
        page: (meta?['page'] as int?) ?? 1,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<RedemptionValidation> validateRedemption(int pointsToRedeem) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.loyaltyRedeem,
        data: {'pointsToRedeem': pointsToRedeem},
      );
      return RedemptionValidation.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
