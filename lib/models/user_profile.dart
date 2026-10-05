import 'package:patogh/models/user_role.dart';

class UserProfile {
  final String name;
  final int age;
  final String city;

  final List<String> interests;

  final String education;
  final String maritalStatus;
  final bool hasChildren;
  final String militaryStatus;

  final String personalityType;
  final String leisureStyle;
  final List<String> personalityTags;

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
    this.education = '',
    this.maritalStatus = '',
    this.hasChildren = false,
    this.militaryStatus = '',
    this.personalityType = '',
    this.leisureStyle = '',
    this.personalityTags = const [],
    this.role = UserRole.participant,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? city,
    List<String>? interests,
    String? education,
    String? maritalStatus,
    bool? hasChildren,
    String? militaryStatus,
    String? personalityType,
    String? leisureStyle,
    List<String>? personalityTags,
    bool? showAge,
    bool? allowChat,
    UserRole? role,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      city: city ?? this.city,
      interests: interests ?? this.interests,
      education: education ?? this.education,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      hasChildren: hasChildren ?? this.hasChildren,
      militaryStatus: militaryStatus ?? this.militaryStatus,
      personalityType: personalityType ?? this.personalityType,
      leisureStyle: leisureStyle ?? this.leisureStyle,
      personalityTags: personalityTags ?? this.personalityTags,
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
        'education': education,
        'maritalStatus': maritalStatus,
        'hasChildren': hasChildren,
        'militaryStatus': militaryStatus,
        'personalityType': personalityType,
        'leisureStyle': leisureStyle,
        'personalityTags': personalityTags,
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
        (json['interests'] as List?) ?? const [],
      ),
      education: (json['education'] as String?) ?? '',
      maritalStatus: (json['maritalStatus'] as String?) ?? '',
      hasChildren: (json['hasChildren'] as bool?) ?? false,
      militaryStatus: (json['militaryStatus'] as String?) ?? '',
      personalityType: (json['personalityType'] as String?) ?? '',
      leisureStyle: (json['leisureStyle'] as String?) ?? '',
      personalityTags: List<String>.from(
        (json['personalityTags'] as List?) ?? const [],
      ),
      showAge: (json['showAge'] as bool?) ?? true,
      allowChat: (json['allowChat'] as bool?) ?? true,
      role: UserRoleX.fromKey(json['role'] as String?),
    );
  }
}
