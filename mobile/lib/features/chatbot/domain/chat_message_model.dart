import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coffee_card/features/shop/domain/modifier_model.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

enum ChatRole { user, assistant }

/// A product the assistant recommended inline in the conversation.
@freezed
class ChatProductRef with _$ChatProductRef {
  const factory ChatProductRef({
    required String id,
    required String slug,
    required String name,
    @Default('') String image,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: numToDouble) @Default(0.0) double price,
    String? meta,
  }) = _ChatProductRef;

  factory ChatProductRef.fromJson(Map<String, dynamic> json) =>
      _$ChatProductRefFromJson(json);
}

@freezed
class ChatMessageModel with _$ChatMessageModel {
  const factory ChatMessageModel({
    required String id,
    required ChatRole role,
    required String content,
    required DateTime timestamp,
    @Default(false) bool isLoading,
    ChatProductRef? product,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
}

@freezed
class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    required String sessionId,
    required String reply,
    ChatProductRef? product,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);
}
