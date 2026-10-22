import 'package:patogh/models/user_role.dart';

class UserProfile {
  final String name;
  final int age;
  final String city;

  final List<String> interests;
  final String avatarUrl;

  final String education;
  final String maritalStatus;
  final bool? hasChildren;
  final String militaryStatus;

  final String personalityType;
  final String leisureStyle;
  final List<String> personalityTags;
  final Map<String, String> personalityAnswers;

  final bool showAge;
  final bool allowChat;
  final UserRole role;

  const UserProfile({
    required this.name,
    required this.age,
    required this.city,
    required this.interests,
    this.avatarUrl = '',
    required this.showAge,
    required this.allowChat,
    this.education = '',
    this.maritalStatus = '',
    this.hasChildren,
    this.militaryStatus = '',
    this.personalityType = '',
    this.leisureStyle = '',
    this.personalityTags = const [],
    this.personalityAnswers = const {},
    this.role = UserRole.participant,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? city,
    List<String>? interests,
    String? avatarUrl,
    String? education,
    String? maritalStatus,
    bool? hasChildren,
    String? militaryStatus,
    String? personalityType,
    String? leisureStyle,
    List<String>? personalityTags,
    Map<String, String>? personalityAnswers,
    bool? showAge,
    bool? allowChat,
    UserRole? role,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      city: city ?? this.city,
      interests: interests ?? this.interests,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      education: education ?? this.education,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      hasChildren: hasChildren ?? this.hasChildren,
      militaryStatus: militaryStatus ?? this.militaryStatus,
      personalityType: personalityType ?? this.personalityType,
      leisureStyle: leisureStyle ?? this.leisureStyle,
      personalityTags: personalityTags ?? this.personalityTags,
      personalityAnswers: personalityAnswers ?? this.personalityAnswers,
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
    'avatarUrl': avatarUrl,
    'education': education,
    'maritalStatus': maritalStatus,
    'hasChildren': hasChildren,
    'militaryStatus': militaryStatus,
    'personalityType': personalityType,
    'leisureStyle': leisureStyle,
    'personalityTags': personalityTags,
    'personalityAnswers': personalityAnswers,
    'showAge': showAge,
    'allowChat': allowChat,
    'role': role.key,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?) ?? 'کاربر پاتوق',
      age: (json['age'] as num?)?.toInt() ?? 25,
      city: (json['city'] as String?) ?? 'مشهد',
      interests: List<String>.from((json['interests'] as List?) ?? const []),
      avatarUrl: (json['avatarUrl'] as String?) ?? '',
      education: (json['education'] as String?) ?? '',
      maritalStatus: (json['maritalStatus'] as String?) ?? '',
      hasChildren: json['hasChildren'] as bool?,
      militaryStatus: (json['militaryStatus'] as String?) ?? '',
      personalityType: (json['personalityType'] as String?) ?? '',
      leisureStyle: (json['leisureStyle'] as String?) ?? '',
      personalityTags: List<String>.from(
        (json['personalityTags'] as List?) ?? const [],
      ),
      personalityAnswers: Map<String, String>.from(
        (json['personalityAnswers'] as Map?) ?? const <String, String>{},
      ),
      showAge: (json['showAge'] as bool?) ?? true,
      allowChat: (json['allowChat'] as bool?) ?? true,
      role: UserRoleX.fromKey(json['role'] as String?),
    );
  }
}
