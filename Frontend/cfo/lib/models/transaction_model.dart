class TransactionModel {
  final String id;
  final String companyId;
  final String date;
  final String description;
  final double amount;
  final String type;
  final String category;

  TransactionModel({
    required this.id,
    required this.companyId,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      category: json['category'] ?? '',
    );
  }
}