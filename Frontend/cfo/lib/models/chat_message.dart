class ChatMessage {
  final String? id;
  final String role;
  final String content;
  final String? createdAt;
  final List<String>? suggestedQuestions;

  ChatMessage({
    this.id,
    required this.role,
    required this.content,
    this.createdAt,
    this.suggestedQuestions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      createdAt: json['created_at'],
    );
  }
}