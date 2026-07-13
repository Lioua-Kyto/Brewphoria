import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/features/shop/data/product_remote_datasource.dart';
import 'package:coffee_card/features/shop/domain/product_model.dart';
import 'package:coffee_card/features/reviews/domain/review_model.dart';
import 'package:coffee_card/features/reviews/data/review_remote_datasource.dart';

part 'product_detail_provider.g.dart';

@riverpod
Future<ProductModel> productDetail(Ref ref, String slug) async {
  return ProductRemoteDatasource().getProductBySlug(slug);
}

final productReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, productId) {
  return ReviewRemoteDatasource().getProductReviewsForProduct(productId);
});

final productReviewSummaryProvider =
    FutureProvider.family<ReviewSummary, String>((ref, productId) {
  return ReviewRemoteDatasource().getProductReviewSummary(productId);
});
