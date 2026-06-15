import '../models/dashboard_metrics.dart';
import '../models/financial_data.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';
import '../models/forecast_result.dart';
import '../models/advisor_model.dart';
import '../models/report_data.dart';
import '../models/user.dart';
import '../models/chat_message.dart';

class MockDataService {
  // Singleton
  static final MockDataService _instance = MockDataService._();
  factory MockDataService() => _instance;
  MockDataService._();

  // Mock user
  final Map<String, dynamic> mockUser = {
    'id': 'mock-user-001',
    'name': 'Alex Rivera',
    'email': 'alex@startup.co',
    'role': 'founder',
  };

  final Map<String, dynamic> mockCompany = {
    'name': 'TechFlow Inc.',
    'industry': 'SaaS',
    'monthly_revenue': 185000.0,
    'monthly_expenses': 125000.0,
    'employees': 28,
  };

  DashboardMetrics getMockMetrics() {
    return DashboardMetrics(
      cashBalance: 1245000,
      monthlyRevenue: 185000,
      monthlyExpenses: 125000,
      netProfit: 60000,
      burnRate: 95000,
      runway: 13,
      revenueChange: 12.5,
      expenseChange: 3.2,
      profitMargin: 32.4,
      companyName: 'TechFlow Inc.',
      industry: 'SaaS',
      employees: 28,
    );
  }

  List<FinancialData> getMockTrends() {
    final data = <FinancialData>[];
    final now = DateTime.now();
    double cash = 500000;
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final revenue = 120000 + (11 - i) * 6500 + (i % 3) * 3000;
      final expenses = 85000 + (11 - i) * 3500 + (i % 2) * 2000;
      cash += revenue - expenses;
      data.add(
        FinancialData(
          date: date.toIso8601String().substring(0, 7),
          revenue: revenue.toDouble(),
          expenses: expenses.toDouble(),
          cashBalance: cash,
          actual: true,
        ),
      );
    }
    return data;
  }

  Map<String, dynamic> getMockActivity() {
    final transactions = <TransactionModel>[
      TransactionModel(
        id: 'txn-1',
        companyId: 'mock-co',
        date: '2026-06-12',
        description: 'Client payment - Acme Corp',
        amount: 45000,
        type: 'income',
        category: 'Revenue',
      ),
      TransactionModel(
        id: 'txn-2',
        companyId: 'mock-co',
        date: '2026-06-11',
        description: 'SaaS subscription revenue',
        amount: 28500,
        type: 'income',
        category: 'Subscriptions',
      ),
      TransactionModel(
        id: 'txn-3',
        companyId: 'mock-co',
        date: '2026-06-10',
        description: 'Cloud infrastructure - AWS',
        amount: 12400,
        type: 'expense',
        category: 'Infrastructure',
      ),
      TransactionModel(
        id: 'txn-4',
        companyId: 'mock-co',
        date: '2026-06-09',
        description: 'Employee salaries',
        amount: 58000,
        type: 'expense',
        category: 'Payroll',
      ),
      TransactionModel(
        id: 'txn-5',
        companyId: 'mock-co',
        date: '2026-06-08',
        description: 'Consulting fees - TechCo',
        amount: 15000,
        type: 'income',
        category: 'Services',
      ),
      TransactionModel(
        id: 'txn-6',
        companyId: 'mock-co',
        date: '2026-06-07',
        description: 'Marketing campaign - Google Ads',
        amount: 8500,
        type: 'expense',
        category: 'Marketing',
      ),
      TransactionModel(
        id: 'txn-7',
        companyId: 'mock-co',
        date: '2026-06-06',
        description: 'License renewal - DataSys',
        amount: 12000,
        type: 'income',
        category: 'Licenses',
      ),
    ];
    final notifications = <NotificationModel>[
      NotificationModel(
        id: 'notif-1',
        userId: 'mock-user',
        title: 'Monthly Report Ready',
        message: 'Your June financial summary is available',
        type: 'info',
        read: false,
        createdAt:
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      NotificationModel(
        id: 'notif-2',
        userId: 'mock-user',
        title: 'Unusual Expense Detected',
        message: 'Marketing spend increased 25% this month',
        type: 'warning',
        read: false,
        createdAt:
            DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      ),
      NotificationModel(
        id: 'notif-3',
        userId: 'mock-user',
        title: 'Fundraising Opportunity',
        message: 'Your readiness score is now 78/100',
        type: 'success',
        read: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      NotificationModel(
        id: 'notif-4',
        userId: 'mock-user',
        title: 'Cash Runway Alert',
        message: 'Runway extended to 13 months',
        type: 'success',
        read: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      ),
    ];
    return {'transactions': transactions, 'notifications': notifications};
  }

  ForecastResult getMockForecast({
    int months = 12,
    double revenueGrowth = 5,
    double expenseGrowth = 3,
  }) {
    final historical = <FinancialDataWrapper>[];
    final projections = <ForecastProjection>[];
    final now = DateTime.now();
    double cash = 1245000;

    // Historical
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final rev = 120000 + (11 - i) * 6500;
      final exp = 85000 + (11 - i) * 3500;
      cash += rev - exp;
      historical.add(
        FinancialDataWrapper(
          date: date.toIso8601String().substring(0, 7),
          revenue: rev.toDouble(),
          expenses: exp.toDouble(),
          cashBalance: cash,
          actual: true,
        ),
      );
    }

    // Projections
    double currentRev = historical.last.revenue;
    double currentExp = historical.last.expenses;
    for (int i = 1; i <= months; i++) {
      currentRev *= (1 + revenueGrowth / 100);
      currentExp *= (1 + expenseGrowth / 100);
      cash += currentRev - currentExp;
      projections.add(
        ForecastProjection(
          date: DateTime(
            now.year,
            now.month + i,
            1,
          ).toIso8601String().substring(0, 7),
          revenue: currentRev,
          expenses: currentExp,
          cashBalance: cash < 0 ? 0 : cash,
          month: i,
        ),
      );
    }

    final avgExpenses =
        historical.fold(0.0, (s, d) => s + d.expenses) / historical.length;
    final burnRate = avgExpenses * 0.8;
    final runway = burnRate > 0 ? (cash / burnRate).round() : 999;

    return ForecastResult(
      historical: historical,
      projections: projections,
      currentCash: cash,
      currentBurnRate: burnRate.round(),
      currentRunway: runway,
    );
  }

  List<AdvisorModel> getMockAdvisors() {
    return [
      AdvisorModel(
        id: 'adv-1',
        name: 'Sarah Chen',
        photo: null,
        experience: 15,
        rating: 4.9,
        specialization: 'SaaS & Enterprise',
        region: 'North America',
        bio:
            'Former CFO of three unicorn startups. Specializing in SaaS metrics, fundraising strategy, and financial operations at scale.',
        availability: 'Available',
        pricePerHour: 250,
      ),
      AdvisorModel(
        id: 'adv-2',
        name: 'Marcus Johnson',
        photo: null,
        experience: 12,
        rating: 4.8,
        specialization: 'Early Stage Growth',
        region: 'Europe',
        bio:
            'Helped 50+ startups from pre-seed to Series B. Expert in unit economics, runway optimization, and investor relations.',
        availability: 'Available',
        pricePerHour: 200,
      ),
      AdvisorModel(
        id: 'adv-3',
        name: 'Priya Patel',
        photo: null,
        experience: 18,
        rating: 4.9,
        specialization: 'Fintech & Compliance',
        region: 'Asia Pacific',
        bio:
            'Big 4 trained CFO with deep fintech expertise. Regulatory compliance, risk management, and international expansion.',
        availability: 'Available',
        pricePerHour: 300,
      ),
      AdvisorModel(
        id: 'adv-4',
        name: 'James Wilson',
        photo: null,
        experience: 10,
        rating: 4.7,
        specialization: 'E-commerce & D2C',
        region: 'North America',
        bio:
            'Growth-stage CFO who scaled 3 D2C brands to \$100M+ revenue. Inventory management, cash flow optimization, and FP&A.',
        availability: 'Available',
        pricePerHour: 180,
      ),
      AdvisorModel(
        id: 'adv-5',
        name: 'Elena Rodriguez',
        photo: null,
        experience: 14,
        rating: 4.8,
        specialization: 'Healthcare & Biotech',
        region: 'Europe',
        bio:
            'CFO with PhD in Health Economics. Specialized in medtech, biotech fundraising, and healthcare financial modeling.',
        availability: 'Booked',
        pricePerHour: 275,
      ),
      AdvisorModel(
        id: 'adv-6',
        name: 'David Kim',
        photo: null,
        experience: 20,
        rating: 4.9,
        specialization: 'M&A & Corporate Strategy',
        region: 'Asia Pacific',
        bio:
            'Former investment banker turned CFO. M&A strategy, corporate restructuring, and capital markets expertise.',
        availability: 'Available',
        pricePerHour: 350,
      ),
    ];
  }

  Map<String, dynamic> getMockAdvisorDetail(String id) {
    final advisors = getMockAdvisors();
    final advisor = advisors.firstWhere(
      (a) => a.id == id,
      orElse: () => advisors.first,
    );
    return {
      'advisor': advisor,
      'reviews': [
        ReviewModel(id: 'rev-1', advisorId: id, rating: 5, comment: 'Exceptional financial insight. Transformed our fundraising strategy.'),
        ReviewModel(id: 'rev-2', advisorId: id, rating: 5, comment: 'Incredible depth of knowledge. Highly recommend for any startup.'),
        ReviewModel(id: 'rev-3', advisorId: id, rating: 4, comment: 'Practical advice that saved us months of runway.'),
      ],
    };
  }

  Map<String, dynamic> getMockNotifications() {
    final notifications = <NotificationModel>[
      NotificationModel(
        id: 'n-1',
        userId: 'mock-user',
        title: 'Monthly Report Ready',
        message: 'Your June financial summary is available for review',
        type: 'info',
        read: false,
        createdAt:
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      NotificationModel(
        id: 'n-2',
        userId: 'mock-user',
        title: 'Expense Spike Detected',
        message: 'Marketing spend increased 25% this month compared to last',
        type: 'warning',
        read: false,
        createdAt:
            DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      ),
      NotificationModel(
        id: 'n-3',
        userId: 'mock-user',
        title: 'Fundraising Ready',
        message: 'Your readiness score improved to 78/100',
        type: 'success',
        read: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      NotificationModel(
        id: 'n-4',
        userId: 'mock-user',
        title: 'New Advisor Available',
        message: 'David Kim, M&A specialist, is now available for consultation',
        type: 'info',
        read: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      ),
      NotificationModel(
        id: 'n-5',
        userId: 'mock-user',
        title: 'AI Insights Ready',
        message: 'New financial insights and recommendations are available',
        type: 'info',
        read: false,
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 12))
            .toIso8601String(),
      ),
      NotificationModel(
        id: 'n-6',
        userId: 'mock-user',
        title: 'Cash Runway Update',
        message: 'Runway extended to 13 months based on latest projections',
        type: 'success',
        read: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      ),
      NotificationModel(
        id: 'n-7',
        userId: 'mock-user',
        title: 'Booking Confirmed',
        message: 'Your consultation with Sarah Chen is confirmed for June 20',
        type: 'info',
        read: true,
        createdAt:
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
    ];
    return {'notifications': notifications, 'unreadCount': 3};
  }

  Map<String, dynamic> getMockProfile() {
    return {'user': mockUser, 'company': mockCompany};
  }

  Map<String, dynamic> getMadiBriefing() {
    return {
      'status': 'warning',
      'healthStatus': 'warning',
      'primaryRisk': 'Burn rate increased 8% last month — payroll is the primary driver.',
      'recommendedAction': 'Review payroll projections before the next forecast cycle.',
      'actionRoute': '/forecast',
      'timestamp': 'Updated just now',
      'sentences': [
        'Runway remaining: 11 months.',
        'Burn rate increased 8% last month — payroll is the primary driver.',
        'Current cash position supports 2 additional hires, not 5.',
        'Review payroll projections before the next forecast cycle.',
      ],
      'action': {
        'label': 'Review Forecast',
        'route': '/forecast',
      },
    };
  }

  Map<String, dynamic> getMadiBriefingHealthy() {
    return {
      'status': 'healthy',
      'healthStatus': 'healthy',
      'primaryRisk': 'No immediate risks identified.',
      'recommendedAction': 'Schedule next forecast review in 14 days.',
      'actionRoute': '/forecast',
      'timestamp': 'Updated just now',
      'sentences': [
        'Runway remaining: 18 months at current burn.',
        'Revenue grew 12% last month — ahead of the 8% target.',
        'Operating margin is 34%, up from 28% in Q1.',
        'No immediate risks identified — next forecast review due in 14 days.',
      ],
      'action': {
        'label': 'View Forecast',
        'route': '/forecast',
      },
    };
  }

  Map<String, dynamic> getMadiBriefingCritical() {
    return {
      'status': 'critical',
      'healthStatus': 'critical',
      'primaryRisk': 'Burn rate increased 22% over 60 days with no corresponding revenue growth.',
      'recommendedAction': 'Initiate bridge financing conversations or reduce monthly burn by ₹3,00,000 within 30 days.',
      'actionRoute': '/reports',
      'timestamp': 'Updated just now',
      'sentences': [
        'Runway remaining: 4 months — immediate action required.',
        'Burn rate increased 22% over 60 days with no corresponding revenue growth.',
        'Current reserves do not support planned Q3 hiring.',
        'Initiate bridge financing conversations or reduce monthly burn by ₹3,00,000 within 30 days.',
      ],
      'action': {
        'label': 'Review Cash Flow',
        'route': '/reports',
      },
    };
  }

  ReportData getMockReport(String type) {
    switch (type) {
      case 'pnl':
        return ReportData(
          type: 'pnl',
          data: {
            'totalRevenue': 185000,
            'cogs': 42500,
            'grossProfit': 142500,
            'totalExpenses': 82500,
            'netProfit': 60000,
            'revenueGrowth': 12.5,
            'profitMargin': 32.4,
            'operatingRatio': 44.6,
          },
        );
      case 'balance-sheet':
        return ReportData(
          type: 'balance-sheet',
          data: {
            'assets': [
              {'name': 'Cash & Equivalents', 'value': 1245000},
              {'name': 'Accounts Receivable', 'value': 285000},
              {'name': 'Equipment', 'value': 150000},
              {'name': 'Intellectual Property', 'value': 500000},
            ],
            'totalAssets': 2180000,
            'liabilities': [
              {'name': 'Accounts Payable', 'value': 95000},
              {'name': 'Deferred Revenue', 'value': 120000},
              {'name': 'Short-term Debt', 'value': 200000},
            ],
            'totalLiabilities': 415000,
            'equity': [
              {'name': 'Common Stock', 'value': 1200000},
              {'name': 'Retained Earnings', 'value': 565000},
            ],
            'totalEquity': 1765000,
          },
        );
      case 'cash-flow':
        return ReportData(
          type: 'cash-flow',
          data: {
            'operating': [
              {'description': 'Net Income', 'value': 60000},
              {'description': 'Depreciation & Amortization', 'value': 12000},
              {'description': 'Accounts Receivable Change', 'value': -15000},
              {'description': 'Accounts Payable Change', 'value': 8500},
            ],
            'netOperating': 65500,
            'investing': [
              {'description': 'Equipment Purchase', 'value': -25000},
              {'description': 'Software Development', 'value': -18000},
            ],
            'netInvesting': -43000,
            'financing': [
              {'description': 'Debt Repayment', 'value': -10000},
              {'description': 'Equity Investment', 'value': 0},
            ],
            'netFinancing': -10000,
            'netCashChange': 12500,
            'beginningCash': 1232500,
            'endingCash': 1245000,
          },
        );
      default:
        return ReportData(type: type, data: {});
    }
  }

  Map<String, dynamic> getMockFundraisingReadiness() {
    return {
      'overallScore': 78,
      'financialHealth': 82,
      'breakdown': {
        'revenueGrowth': 85,
        'profitMargin': 72,
        'cashRunway': 78,
        'burnRate': 70,
        'unitEconomics': 82,
      },
      'details': {
        'avgMonthlyRevenue': 185000,
        'avgMonthlyExpenses': 125000,
        'currentCash': 1245000,
        'monthlyBurnRate': 95000,
        'runwayMonths': 13,
      },
    };
  }

  List<Map<String, dynamic>> getMockDataRoomFiles() {
    return [
      {
        'id': 'file-1',
        'name': 'Financial_Statements_2026.pdf',
        'type': 'pdf',
        'size': '2.4 MB',
        'updatedAt': '2026-06-01',
      },
      {
        'id': 'file-2',
        'name': 'Cap_Table_v4.xlsx',
        'type': 'xlsx',
        'size': '856 KB',
        'updatedAt': '2026-05-28',
      },
      {
        'id': 'file-3',
        'name': 'Business_Plan_2026.pdf',
        'type': 'pdf',
        'size': '3.1 MB',
        'updatedAt': '2026-05-20',
      },
      {
        'id': 'file-4',
        'name': 'Financial_Model_v3.xlsx',
        'type': 'xlsx',
        'size': '1.2 MB',
        'updatedAt': '2026-05-15',
      },
      {
        'id': 'file-5',
        'name': 'Investor_Deck_Q2.pptx',
        'type': 'pptx',
        'size': '4.8 MB',
        'updatedAt': '2026-05-10',
      },
      {
        'id': 'file-6',
        'name': 'Legal_Structure.docx',
        'type': 'docx',
        'size': '425 KB',
        'updatedAt': '2026-05-05',
      },
    ];
  }

  Map<String, dynamic> getMockAdminMetrics() {
    return {
      'totalFounders': 342,
      'totalAdvisors': 28,
      'totalCompanies': 156,
      'activeThisMonth': 245,
      'platformRevenue': 1250000,
      'platformRevenueChange': 8.4,
      'totalBookings': 89,
      'bookingsChange': 12.0,
      'avgSessionMinutes': 18,
      'uptime': 99.9,
      'planDistribution': {
        'premium': 42,
        'standard': 89,
        'basic': 211,
      },
      'recentSignups': [
        {
          'name': 'NeoFinance Ltd',
          'role': 'founder',
          'plan': 'Premium',
          'daysAgo': 1
        },
        {
          'name': 'Dr. Priya Mehta',
          'role': 'advisor',
          'plan': 'Pro',
          'daysAgo': 2
        },
        {
          'name': 'GreenScale Inc',
          'role': 'founder',
          'plan': 'Standard',
          'daysAgo': 3
        },
        {
          'name': 'HealthBridge Co',
          'role': 'founder',
          'plan': 'Basic',
          'daysAgo': 4
        },
        {
          'name': 'Dr. Arun Nair',
          'role': 'advisor',
          'plan': 'Pro',
          'daysAgo': 5
        },
      ],
      'advisorPipeline': [
        {
          'name': 'Sarah Chen',
          'status': 'Verified',
          'clients': 8,
          'rating': 4.9
        },
        {
          'name': 'Marcus Johnson',
          'status': 'Verified',
          'clients': 6,
          'rating': 4.8
        },
        {
          'name': 'Priya Patel',
          'status': 'Verified',
          'clients': 11,
          'rating': 4.9
        },
        {
          'name': 'Michael Brown',
          'status': 'Pending',
          'clients': 0,
          'rating': 0.0
        },
        {
          'name': 'James Wilson',
          'status': 'Suspended',
          'clients': 0,
          'rating': 4.7
        },
      ],
      'monthlyGrowth': [
        {'month': 'Jan', 'founders': 280, 'revenue': 980000},
        {'month': 'Feb', 'founders': 295, 'revenue': 1020000},
        {'month': 'Mar', 'founders': 308, 'revenue': 1080000},
        {'month': 'Apr', 'founders': 315, 'revenue': 1120000},
        {'month': 'May', 'founders': 328, 'revenue': 1180000},
        {'month': 'Jun', 'founders': 342, 'revenue': 1250000},
      ],
      'alerts': [
        {
          'type': 'warning',
          'message': 'Michael Brown verification pending for 5 days'
        },
        {
          'type': 'info',
          'message': '3 new founder signups in the last 24 hours'
        },
        {
          'type': 'success',
          'message': 'Platform uptime maintained at 99.9% this month'
        },
      ],
    };
  }

  Map<String, dynamic> getMockAdvisorMetrics() {
    return {
      'advisorName': 'Sarah Chen',
      'specialization': 'SaaS & Enterprise',
      'rating': 4.9,
      'totalClients': 8,
      'activeEngagements': 5,
      'completedSessions': 47,
      'upcomingBookings': [
        {
          'client': 'TechFlow Inc.',
          'date': 'Jun 18',
          'time': '10:00 AM',
          'topic': 'Runway analysis'
        },
        {
          'client': 'NeoFinance',
          'date': 'Jun 20',
          'time': '2:00 PM',
          'topic': 'Series A prep'
        },
        {
          'client': 'GreenScale',
          'date': 'Jun 22',
          'time': '11:00 AM',
          'topic': 'Cash flow review'
        },
      ],
      'clientHealth': [
        {'name': 'TechFlow Inc.', 'runway': 13, 'status': 'healthy'},
        {'name': 'NeoFinance', 'runway': 7, 'status': 'warning'},
        {'name': 'GreenScale', 'runway': 4, 'status': 'critical'},
        {'name': 'EduLearn', 'runway': 18, 'status': 'healthy'},
        {'name': 'HealthPlus', 'runway': 11, 'status': 'healthy'},
      ],
      'recentActivity': [
        {
          'client': 'TechFlow Inc.',
          'action': 'Session completed',
          'daysAgo': 2
        },
        {'client': 'NeoFinance', 'action': 'Report shared', 'daysAgo': 3},
        {'client': 'GreenScale', 'action': 'Alert: Low runway', 'daysAgo': 4},
      ],
    };
  }

  Future<Map<String, dynamic>> mockChat(String message) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final responses = [
      'Based on your current financial data, your cash runway is approximately 13 months at the current burn rate of \$95,000/month. I recommend focusing on increasing revenue growth to extend this further.',
      'Your profit margin of 32.4% is healthy for a SaaS company. The industry average is around 25-35%. To improve, consider optimizing your cloud infrastructure costs which currently account for 15% of expenses.',
      'Looking at your revenue trend, you\'ve grown at 12.5% month-over-month. At this rate, you\'re on track to reach \$250K MRR within 6 months. I recommend preparing your Series A materials now.',
      'Your expense growth of 3.2% is well controlled relative to revenue growth. However, I notice marketing spend increased 25% this month. Let me know if you\'d like me to analyze the ROI.',
      'For fundraising readiness, your score of 78/100 is strong. Key areas to improve: unit economics documentation and a more detailed market analysis. Would you like me to help draft your investor memo?',
    ];
    return {
      'response': responses[message.length % responses.length],
      'suggestedQuestions': [
        'How can I improve my profit margin?',
        'What\'s my optimal burn rate?',
        'When should I raise my Series A?',
        'How do I compare to industry benchmarks?',
        'Can you analyze my expense categories?',
      ],
    };
  }
}
