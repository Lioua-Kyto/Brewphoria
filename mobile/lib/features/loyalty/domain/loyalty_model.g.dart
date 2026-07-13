// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoyaltyModelImpl _$$LoyaltyModelImplFromJson(Map<String, dynamic> json) =>
    _$LoyaltyModelImpl(
      id: json['id'] as String,
      currentPoints: (json['currentPoints'] as num).toInt(),
      lifetimePoints: (json['lifetimePoints'] as num).toInt(),
      tier: json['tier'] as String,
    );

Map<String, dynamic> _$$LoyaltyModelImplToJson(_$LoyaltyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currentPoints': instance.currentPoints,
      'lifetimePoints': instance.lifetimePoints,
      'tier': instance.tier,
    };

_$LoyaltyTransactionModelImpl _$$LoyaltyTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LoyaltyTransactionModelImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      points: (json['points'] as num).toInt(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LoyaltyTransactionModelImplToJson(
        _$LoyaltyTransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'points': instance.points,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$RedemptionValidationImpl _$$RedemptionValidationImplFromJson(
        Map<String, dynamic> json) =>
    _$RedemptionValidationImpl(
      pointsToRedeem: (json['pointsToRedeem'] as num).toInt(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      remainingPoints: (json['remainingPoints'] as num).toInt(),
    );

Map<String, dynamic> _$$RedemptionValidationImplToJson(
        _$RedemptionValidationImpl instance) =>
    <String, dynamic>{
      'pointsToRedeem': instance.pointsToRedeem,
      'discountAmount': instance.discountAmount,
      'remainingPoints': instance.remainingPoints,
    };
