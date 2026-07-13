import 'package:dio/dio.dart';
import 'package:coffee_card/core/constants/api_endpoints.dart';
import 'package:coffee_card/core/network/dio_client.dart';
import 'package:coffee_card/features/reviews/domain/review_model.dart';

/// Exact rating aggregates for a product, computed server-side across all
/// visible reviews (not just the loaded page).
class ReviewSummary {
  const ReviewSummary({
    required this.average,
    required this.count,
    required this.distribution,
  });

  final double average;
  final int count;

  /// Star (1–5) → number of reviews at that rating.
  final Map<int, int> distribution;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    final dist = (json['distribution'] as Map<String, dynamic>?) ?? const {};
    return ReviewSummary(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      distribution: {
        for (var star = 1; star <= 5; star++)
          star: (dist['$star'] as num?)?.toInt() ?? 0,
      },
    );
  }
}

class ReviewRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<ReviewModel> createReview(CreateReviewRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.reviews,
        data: {
          'orderItemId': request.orderItemId,
          'rating': request.rating,
          'comment': request.comment,
          'images': request.images,
        },
      );
      return ReviewModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ReviewModel> updateReview(
    String id, {
    int? rating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.reviewById(id),
        data: {
          if (rating != null) 'rating': rating,
          if (comment != null) 'comment': comment,
          if (images != null) 'images': images,
        },
      );
      return ReviewModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      await _dio.delete<void>(ApiEndpoints.reviewById(id));
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ReviewSummary> getProductReviewSummary(String productId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.productReviewSummary(productId),
      );
      return ReviewSummary.fromJson(
          response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<ReviewModel>> getProductReviewsForProduct(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.productReviews(productId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data!['data'] as List<dynamic>;
      return data
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
