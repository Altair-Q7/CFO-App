class ApiConstants {
  static const String baseUrl = 'http://localhost:3001/api';
  
  // Auth
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String onboarding = '/auth/onboarding';
  
  // Dashboard
  static const String dashboardMetrics = '/dashboard/metrics';
  static const String dashboardTrends = '/dashboard/trends';
  static const String dashboardActivity = '/dashboard/activity';
  
  // Forecasting
  static const String forecastingProject = '/forecasting/project';
  
  // AI Assistant
  static const String aiChat = '/ai/chat';
  static const String aiHistory = '/ai/history';
  static const String aiSuggestions = '/ai/suggestions';
  
  // Reports
  static const String reports = '/reports';
  static String reportById(String type) => '/reports/$type';
  static String reportPdf(String type) => '/reports/$type/pdf';
  
  // Marketplace
  static const String marketplaceAdvisors = '/marketplace/advisors';
  static String advisorById(String id) => '/marketplace/advisors/$id';
  static const String marketplaceBook = '/marketplace/book';
  
  // Fundraising
  static const String fundraisingReadiness = '/fundraising/readiness';
  static const String fundraisingDataRoom = '/fundraising/data-room';
  
  // Notifications
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  
  // Profile
  static const String profile = '/profile';
  
  // Health
  static const String health = '/health';
}