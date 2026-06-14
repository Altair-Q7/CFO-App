import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_message.dart';
import '../services/mock_data_service.dart';

class AiService {
  final ApiClient _client;
  final bool _useMock;

  AiService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<Map<String, dynamic>> chat(String message,
      {List<Map<String, dynamic>>? history}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockDataService().mockChat(message);
    }
    try {
      final data = await _client.post(ApiConstants.aiChat, body: {
        'message': message,
        'history': history ?? [],
      });
      return {
        'response': data['response'] ?? '',
        'metrics': data['metrics'],
        'suggestedQuestions':
            List<String>.from(data['suggestedQuestions'] ?? []),
      };
    } catch (_) {
      return MockDataService().mockChat(message);
    }
  }

  Future<List<ChatMessage>> getHistory() async {
    if (_useMock) {
      return [];
    }
    try {
      final data = await _client.get(ApiConstants.aiHistory);
      final history = data['history'] as List? ?? [];
      return history.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getSuggestions() async {
    if (_useMock) {
      return [
        'How can I improve my profit margin?',
        'What\'s my optimal burn rate?',
        'When should I raise my Series A?',
      ];
    }
    try {
      final data = await _client.get(ApiConstants.aiSuggestions, auth: false);
      return List<String>.from(data['suggestions'] ?? []);
    } catch (_) {
      return [];
    }
  }
}
