import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/features/reviews/data/review_remote_datasource.dart';
import 'package:coffee_card/features/reviews/domain/review_model.dart';

part 'review_provider.g.dart';

@riverpod
ReviewRemoteDatasource reviewDataSource(Ref ref) => ReviewRemoteDatasource();

@riverpod
class ReviewNotifier extends _$ReviewNotifier {
  @override
  AsyncValue<ReviewModel?> build() => const AsyncValue.data(null);

  Future<ReviewModel?> submitReview(CreateReviewRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(reviewDataSourceProvider).createReview(request),
    );
    return state.valueOrNull;
  }
}
