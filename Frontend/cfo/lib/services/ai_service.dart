import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_message.dart';

class AiService {
  final ApiClient _client;
  AiService(this._client);

  Future<Map<String, dynamic>> chat(String message, {List<Map<String, dynamic>>? history}) async {
    final data = await _client.post(ApiConstants.aiChat, body: {
      'message': message,
      'history': history ?? [],
    });
    return {
      'response': data['response'] ?? '',
      'metrics': data['metrics'],
      'suggestedQuestions': List<String>.from(data['suggestedQuestions'] ?? []),
    };
  }

  Future<List<ChatMessage>> getHistory() async {
    final data = await _client.get(ApiConstants.aiHistory);
    final history = data['history'] as List? ?? [];
    return history.map((e) => ChatMessage.fromJson(e)).toList();
  }

  Future<List<String>> getSuggestions() async {
    final data = await _client.get(ApiConstants.aiSuggestions, auth: false);
    return List<String>.from(data['suggestions'] ?? []);
  }
}