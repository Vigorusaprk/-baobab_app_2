class UserEntity {
  final String id;
  final String name;
  final String? imgUrl;
  final String email;
  final DateTime? loginTime;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.imgUrl,
    this.loginTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imgUrl': imgUrl,
      'email': email,
      'loginTime': loginTime?.toIso8601String(),
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      email: json['email'],
      loginTime: json['loginTime'] != null ? DateTime.parse(json['loginTime']) : null,
    );
  }
}