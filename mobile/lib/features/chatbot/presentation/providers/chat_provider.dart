import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brewphoria/features/chatbot/data/chat_remote_datasource.dart';
import 'package:brewphoria/features/chatbot/domain/chat_message_model.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRemoteDatasource chatDataSource(Ref ref) => ChatRemoteDatasource();

@riverpod
class ChatNotifier extends _$ChatNotifier {
  String? _sessionId;
  bool _isSending = false;

  @override
  List<ChatMessageModel> build() => [];

  bool get isSending => _isSending;
  String? get sessionId => _sessionId;

  Future<void> sendMessage(String content) async {
    if (_isSending || content.trim().isEmpty) return;
    _isSending = true;

    final userMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    final loadingMsg = ChatMessageModel(
      id: 'loading',
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = [...state, userMsg, loadingMsg];

    try {
      final response = await ref
          .read(chatDataSourceProvider)
          .sendMessage(content.trim(), sessionId: _sessionId);
      _sessionId = response.sessionId;

      final assistantMsg = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: ChatRole.assistant,
        content: response.reply,
        timestamp: DateTime.now(),
        product: response.product,
      );

      state = state.where((m) => m.id != 'loading').toList()..add(assistantMsg);
    } catch (e) {
      state = state.where((m) => m.id != 'loading').toList();
      rethrow;
    } finally {
      _isSending = false;
    }
  }

  void clearSession() {
    _sessionId = null;
    state = [];
  }
}
