import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/features/shop/data/product_remote_datasource.dart';
import 'package:brewphoria/features/shop/domain/product_model.dart';
import 'package:brewphoria/features/reviews/domain/review_model.dart';
import 'package:brewphoria/features/reviews/data/review_remote_datasource.dart';

part 'product_detail_provider.g.dart';

@riverpod
Future<ProductModel> productDetail(Ref ref, String slug) async {
  return ProductRemoteDatasource().getProductBySlug(slug);
}

final productReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, productId) {
  return ReviewRemoteDatasource().getProductReviewsForProduct(productId);
});

/// Aggregate rating summary for a product, computed client-side from review data.
class ReviewSummary {
  const ReviewSummary({
    required this.average,
    required this.count,
    required this.distribution,
  });

  final double average;
  final int count;

  /// Mapping of star rating (1-5) → number of reviews with that rating.
  final Map<int, int> distribution;
}

final productReviewSummaryProvider =
    FutureProvider.family<ReviewSummary, String>((ref, productId) async {
  final reviews = await ReviewRemoteDatasource()
      .getProductReviewsForProduct(productId, limit: 100);
  if (reviews.isEmpty) {
    return const ReviewSummary(average: 0, count: 0, distribution: {});
  }
  final dist = <int, int>{};
  for (final r in reviews) {
    dist[r.rating] = (dist[r.rating] ?? 0) + 1;
  }
  final avg = reviews.fold(0.0, (s, r) => s + r.rating) / reviews.length;
  return ReviewSummary(
    average: double.parse(avg.toStringAsFixed(1)),
    count: reviews.length,
    distribution: dist,
  );
});
