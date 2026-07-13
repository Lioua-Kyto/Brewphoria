// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewModelImpl _$$ReviewModelImplFromJson(Map<String, dynamic> json) =>
    _$ReviewModelImpl(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] == null
          ? null
          : ReviewUserModel.fromJson(json['user'] as Map<String, dynamic>),
      productId: json['productId'] as String?,
    );

Map<String, dynamic> _$$ReviewModelImplToJson(_$ReviewModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'images': instance.images,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
      'productId': instance.productId,
    };

_$ReviewUserModelImpl _$$ReviewUserModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ReviewUserModelImpl(
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$ReviewUserModelImplToJson(
        _$ReviewUserModelImpl instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
    };

_$CreateReviewRequestImpl _$$CreateReviewRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateReviewRequestImpl(
      orderItemId: json['orderItemId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CreateReviewRequestImplToJson(
        _$CreateReviewRequestImpl instance) =>
    <String, dynamic>{
      'orderItemId': instance.orderItemId,
      'rating': instance.rating,
      'comment': instance.comment,
      'images': instance.images,
    };
