class Company {
  final String id;
  final String name;
  final String industry;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final int employees;

  Company({
    required this.id,
    required this.name,
    required this.industry,
    this.monthlyRevenue = 0,
    this.monthlyExpenses = 0,
    this.employees = 0,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      industry: json['industry'] ?? '',
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      monthlyExpenses: (json['monthly_expenses'] ?? 0).toDouble(),
      employees: json['employees'] ?? 0,
    );
  }
}