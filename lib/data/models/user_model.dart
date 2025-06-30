class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> savedAccommodationIds;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    required this.savedAccommodationIds,
    this.preferences,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      savedAccommodationIds: List<String>.from(map['savedAccommodationIds'] ?? []),
      preferences: map['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'savedAccommodationIds': savedAccommodationIds,
      'preferences': preferences,
    };
  }
}