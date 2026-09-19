import 'package:patogh/models/user_role.dart';

class UserProfile {
  final String name;
  final int age;
  final String city;
  final List<String> interests;
  final bool showAge;
  final bool allowChat;
  final UserRole role;

  const UserProfile({
    required this.name,
    required this.age,
    required this.city,
    required this.interests,
    required this.showAge,
    required this.allowChat,
    this.role = UserRole.participant,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? city,
    List<String>? interests,
    bool? showAge,
    bool? allowChat,
    UserRole? role,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      city: city ?? this.city,
      interests: interests ?? this.interests,
      showAge: showAge ?? this.showAge,
      allowChat: allowChat ?? this.allowChat,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'city': city,
    'interests': interests,
    'showAge': showAge,
    'allowChat': allowChat,
    'role': role.key,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?) ?? 'کاربر پاتوق',
      age: (json['age'] as num?)?.toInt() ?? 25,
      city: (json['city'] as String?) ?? 'مشهد',
      interests: List<String>.from(
        (json['interests'] as List?) ?? const <String>[],
      ),
      showAge: (json['showAge'] as bool?) ?? true,
      allowChat: (json['allowChat'] as bool?) ?? true,
      role: UserRoleX.fromKey(json['role'] as String?),
    );
  }
}
