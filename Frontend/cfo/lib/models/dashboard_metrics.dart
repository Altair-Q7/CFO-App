class DashboardMetrics {
  final double cashBalance;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final double netProfit;
  final int burnRate;
  final int runway;
  final double revenueChange;
  final double expenseChange;
  final double profitMargin;
  final String companyName;
  final String industry;
  final int employees;

  DashboardMetrics({
    required this.cashBalance,
    required this.monthlyRevenue,
    required this.monthlyExpenses,
    required this.netProfit,
    required this.burnRate,
    required this.runway,
    required this.revenueChange,
    required this.expenseChange,
    required this.profitMargin,
    required this.companyName,
    required this.industry,
    required this.employees,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      cashBalance: (json['cashBalance'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] ?? 0).toDouble(),
      netProfit: (json['netProfit'] ?? 0).toDouble(),
      burnRate: json['burnRate'] ?? 0,
      runway: json['runway'] ?? 0,
      revenueChange: (json['revenueChange'] ?? 0).toDouble(),
      expenseChange: (json['expenseChange'] ?? 0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 0).toDouble(),
      companyName: json['companyName'] ?? '',
      industry: json['industry'] ?? '',
      employees: json['employees'] ?? 0,
    );
  }
}