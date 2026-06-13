class FinancialData {
  final String date;
  final double revenue;
  final double expenses;
  final double cashBalance;
  final bool actual;

  FinancialData({
    required this.date,
    required this.revenue,
    required this.expenses,
    required this.cashBalance,
    this.actual = false,
  });

  factory FinancialData.fromJson(Map<String, dynamic> json) {
    return FinancialData(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      cashBalance: (json['cashBalance'] ?? json['cash_balance'] ?? 0).toDouble(),
      actual: json['actual'] ?? false,
    );
  }
}