class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isPremium = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isPremium: map['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isPremium': isPremium,
    };
  }
}
