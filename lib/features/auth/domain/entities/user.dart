class UserEntity {
  final String id;
  final String name;
  final String? imgUrl; // ✅ nullable
  final String email;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imgUrl,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imgUrl': imgUrl,
      'email': email,
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      email: json['email'],
    );
  }
}