import 'package:dio/dio.dart';
import 'package:coffee_card/core/constants/api_endpoints.dart';
import 'package:coffee_card/core/network/dio_client.dart';
import 'package:coffee_card/features/chatbot/domain/chat_message_model.dart';

class ChatRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<ChatResponse> sendMessage(String message, {String? sessionId}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.chatMessage,
        data: {
          'message': message,
          if (sessionId != null) 'sessionId': sessionId,
        },
      );
      return ChatResponse.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
