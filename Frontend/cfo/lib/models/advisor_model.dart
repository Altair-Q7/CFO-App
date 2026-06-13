class AdvisorModel {
  final String id;
  final String name;
  final String? photo;
  final int experience;
  final double rating;
  final String specialization;
  final String region;
  final String? bio;
  final String availability;
  final double pricePerHour;

  AdvisorModel({
    required this.id,
    required this.name,
    this.photo,
    required this.experience,
    required this.rating,
    required this.specialization,
    required this.region,
    this.bio,
    this.availability = 'Available',
    this.pricePerHour = 150,
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'],
      experience: json['experience'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      specialization: json['specialization'] ?? '',
      region: json['region'] ?? '',
      bio: json['bio'],
      availability: json['availability'] ?? 'Available',
      pricePerHour: (json['price_per_hour'] ?? 150).toDouble(),
    );
  }
}

class ReviewModel {
  final String id;
  final String advisorId;
  final String? userId;
  final int rating;
  final String? comment;
  final String? createdAt;

  ReviewModel({
    required this.id,
    required this.advisorId,
    this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      advisorId: json['advisor_id'] ?? '',
      userId: json['user_id'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }
}