// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckoutRequestImpl _$$CheckoutRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CheckoutRequestImpl(
      addressId: json['addressId'] as String,
      pointsToRedeem: (json['pointsToRedeem'] as num?)?.toInt() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      notes: json['notes'] as String?,
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$CheckoutRequestImplToJson(
        _$CheckoutRequestImpl instance) =>
    <String, dynamic>{
      'addressId': instance.addressId,
      'pointsToRedeem': instance.pointsToRedeem,
      'paymentMethod': instance.paymentMethod,
      'notes': instance.notes,
      'tip': instance.tip,
    };
