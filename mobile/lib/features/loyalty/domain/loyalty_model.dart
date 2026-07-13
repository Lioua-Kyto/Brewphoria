import 'package:freezed_annotation/freezed_annotation.dart';

part 'loyalty_model.freezed.dart';
part 'loyalty_model.g.dart';

@freezed
class LoyaltyModel with _$LoyaltyModel {
  const factory LoyaltyModel({
    required String id,
    required int currentPoints,
    required int lifetimePoints,
    required String tier,
  }) = _LoyaltyModel;

  factory LoyaltyModel.fromJson(Map<String, dynamic> json) => _$LoyaltyModelFromJson(json);
}

@freezed
class LoyaltyTransactionModel with _$LoyaltyTransactionModel {
  const factory LoyaltyTransactionModel({
    required String id,
    required String type,
    required int points,
    required String description,
    required DateTime createdAt,
  }) = _LoyaltyTransactionModel;

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyTransactionModelFromJson(json);
}

@freezed
class RedemptionValidation with _$RedemptionValidation {
  const factory RedemptionValidation({
    required int pointsToRedeem,
    required double discountAmount,
    required int remainingPoints,
  }) = _RedemptionValidation;

  factory RedemptionValidation.fromJson(Map<String, dynamic> json) =>
      _$RedemptionValidationFromJson(json);
}
