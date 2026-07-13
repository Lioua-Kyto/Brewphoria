// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatProductRefImpl _$$ChatProductRefImplFromJson(Map<String, dynamic> json) =>
    _$ChatProductRefImpl(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      image: json['image'] as String? ?? '',
      price: json['price'] == null ? 0.0 : numToDouble(json['price']),
      meta: json['meta'] as String?,
    );

Map<String, dynamic> _$$ChatProductRefImplToJson(
        _$ChatProductRefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'image': instance.image,
      'price': instance.price,
      'meta': instance.meta,
    };

_$ChatMessageModelImpl _$$ChatMessageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatMessageModelImpl(
      id: json['id'] as String,
      role: $enumDecode(_$ChatRoleEnumMap, json['role']),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
      product: json['product'] == null
          ? null
          : ChatProductRef.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ChatMessageModelImplToJson(
        _$ChatMessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatRoleEnumMap[instance.role]!,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'isLoading': instance.isLoading,
      'product': instance.product,
    };

const _$ChatRoleEnumMap = {
  ChatRole.user: 'user',
  ChatRole.assistant: 'assistant',
};

_$ChatResponseImpl _$$ChatResponseImplFromJson(Map<String, dynamic> json) =>
    _$ChatResponseImpl(
      sessionId: json['sessionId'] as String,
      reply: json['reply'] as String,
      product: json['product'] == null
          ? null
          : ChatProductRef.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ChatResponseImplToJson(_$ChatResponseImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'reply': instance.reply,
      'product': instance.product,
    };
