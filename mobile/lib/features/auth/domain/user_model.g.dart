// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'USER',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firebaseUid': instance.firebaseUid,
      'email': instance.email,
      'displayName': instance.displayName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'avatarUrl': instance.avatarUrl,
      'role': instance.role,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$LoyaltySummaryImpl _$$LoyaltySummaryImplFromJson(Map<String, dynamic> json) =>
    _$LoyaltySummaryImpl(
      currentPoints: (json['currentPoints'] as num).toInt(),
      lifetimePoints: (json['lifetimePoints'] as num).toInt(),
      tier: json['tier'] as String,
    );

Map<String, dynamic> _$$LoyaltySummaryImplToJson(
        _$LoyaltySummaryImpl instance) =>
    <String, dynamic>{
      'currentPoints': instance.currentPoints,
      'lifetimePoints': instance.lifetimePoints,
      'tier': instance.tier,
    };

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      loyaltySummary: LoyaltySummary.fromJson(
          json['loyaltySummary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'loyaltySummary': instance.loyaltySummary,
    };
