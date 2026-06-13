class ForecastResult {
  final List<FinancialDataWrapper> historical;
  final List<ForecastProjection> projections;
  final double currentCash;
  final int currentBurnRate;
  final int currentRunway;

  ForecastResult({
    required this.historical,
    required this.projections,
    required this.currentCash,
    required this.currentBurnRate,
    required this.currentRunway,
  });

  factory ForecastResult.fromJson(Map<String, dynamic> json) {
    return ForecastResult(
      historical: (json['historical'] as List? ?? []).map((e) => FinancialDataWrapper.fromJson(e)).toList(),
      projections: (json['projections'] as List? ?? []).map((e) => ForecastProjection.fromJson(e)).toList(),
      currentCash: (json['currentCash'] ?? 0).toDouble(),
      currentBurnRate: json['currentBurnRate'] ?? 0,
      currentRunway: json['currentRunway'] ?? 0,
    );
  }
}

class FinancialDataWrapper {
  final String date;
  final double revenue;
  final double expenses;
  final double cashBalance;
  final bool actual;
  final int? month;

  FinancialDataWrapper({
    required this.date,
    required this.revenue,
    required this.expenses,
    required this.cashBalance,
    this.actual = false,
    this.month,
  });

  factory FinancialDataWrapper.fromJson(Map<String, dynamic> json) {
    return FinancialDataWrapper(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      cashBalance: (json['cashBalance'] ?? json['cash_balance'] ?? 0).toDouble(),
      actual: json['actual'] ?? false,
      month: json['month'],
    );
  }
}

class ForecastProjection {
  final String date;
  final double revenue;
  final double expenses;
  final double cashBalance;
  final int month;

  ForecastProjection({
    required this.date,
    required this.revenue,
    required this.expenses,
    required this.cashBalance,
    required this.month,
  });

  factory ForecastProjection.fromJson(Map<String, dynamic> json) {
    return ForecastProjection(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      cashBalance: (json['cash_balance'] ?? 0).toDouble(),
      month: json['month'] ?? 0,
    );
  }
}