import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    required int rating,
    required String comment,
    @Default([]) List<String> images,
    required DateTime createdAt,
    ReviewUserModel? user,
    String? productId,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);
}

@freezed
class ReviewUserModel with _$ReviewUserModel {
  const factory ReviewUserModel({
    required String displayName,
    String? avatarUrl,
  }) = _ReviewUserModel;

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) => _$ReviewUserModelFromJson(json);
}

@freezed
class CreateReviewRequest with _$CreateReviewRequest {
  const factory CreateReviewRequest({
    required String orderItemId,
    required int rating,
    required String comment,
    @Default([]) List<String> images,
  }) = _CreateReviewRequest;

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);
}
