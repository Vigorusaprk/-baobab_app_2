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

  Review({required this.id, required this.businessId, required this.userId,
    required this.rating, this.comment, required this.createdAt, this.updatedAt,
    this.userName, this.userAvatar});

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    businessId: json['business_id'],
    userId: json['user_id'],
    rating: json['rating'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    userName: json['user_name'],
    userAvatar: json['user_avatar'],
  );
}