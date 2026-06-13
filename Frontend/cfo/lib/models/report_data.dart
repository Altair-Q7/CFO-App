class ReportData {
  final String type;
  final Map<String, dynamic> data;
  final dynamic company;

  ReportData({required this.type, required this.data, this.company});

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      type: json['type'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      company: json['company'],
    );
  }
}

class FundraisingReadiness {
  final int overallScore;
  final int financialHealth;
  final Map<String, double>? breakdown;
  final Map<String, dynamic>? details;

  FundraisingReadiness({
    required this.overallScore,
    required this.financialHealth,
    this.breakdown,
    this.details,
  });

  factory FundraisingReadiness.fromJson(Map<String, dynamic> json) {
    return FundraisingReadiness(
      overallScore: json['overallScore'] ?? 0,
      financialHealth: json['financialHealth'] ?? 0,
      breakdown: json['breakdown'] != null
          ? Map<String, double>.from(
              (json['breakdown'] as Map).map((k, v) => MapEntry(k.toString(), (v ?? 0).toDouble())))
          : null,
      details: json['details'] != null ? Map<String, dynamic>.from(json['details']) : null,
    );
  }
}

class DataRoomFile {
  final String id;
  final String name;
  final String type;
  final String size;
  final String updatedAt;
  final String icon;

  DataRoomFile({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.updatedAt,
    required this.icon,
  });

  factory DataRoomFile.fromJson(Map<String, dynamic> json) {
    return DataRoomFile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}