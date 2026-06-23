class Review {
  final int id;
  final String businessId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final String? userAvatar;

  Review({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    int parseToInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Review(
      id: parseToInt(json['id']),
      businessId: json['business_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      rating: parseToInt(json['rating']),
      comment: json['comment']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,
      userName: json['user_name']?.toString(),
      userAvatar: json['user_avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_name': userName,
      'user_avatar': userAvatar,
    };
  }
}