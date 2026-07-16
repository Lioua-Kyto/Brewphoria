import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';
import 'package:brewphoria/features/reviews/domain/review_model.dart';

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
