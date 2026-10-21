import 'package:flutter_test/flutter_test.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/models/user_role.dart';

void main() {
  test('V14 profile round-trips interests, optional fields and quiz answers', () {
    const profile = UserProfile(
      name: 'کاربر آزمایشی',
      age: 29,
      city: 'مشهد',
      interests: ['کافه و دورهمی', 'سفر و طبیعت'],
      education: 'کارشناسی',
      maritalStatus: 'ترجیح می‌دهم نگویم',
      hasChildren: null,
      militaryStatus: '',
      personalityType: 'اجتماعیِ منعطف',
      leisureStyle: 'طبیعت و تجربه‌های تازه',
      personalityTags: ['اجتماعی', 'طبیعت', 'منعطف'],
      personalityAnswers: {
        'q1': 'معمولاً خودم سر صحبت را باز می‌کنم.',
        'q2': 'جمع کوچک که فرصت گفت‌وگوی عمیق داشته باشیم.',
      },
      showAge: false,
      allowChat: true,
      role: UserRole.participant,
    );

    final restored = UserProfile.fromJson(profile.toJson());
    expect(restored.interests, profile.interests);
    expect(restored.education, profile.education);
    expect(restored.hasChildren, isNull);
    expect(restored.personalityType, profile.personalityType);
    expect(restored.leisureStyle, profile.leisureStyle);
    expect(restored.personalityTags, profile.personalityTags);
    expect(restored.personalityAnswers, profile.personalityAnswers);
    expect(restored.showAge, isFalse);
  });
}
