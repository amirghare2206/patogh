enum UserRole { participant, venue, coordinator, organizer, admin }

extension UserRoleX on UserRole {
  String get key {
    switch (this) {
      case UserRole.participant:
        return 'participant';
      case UserRole.venue:
        return 'venue';
      case UserRole.coordinator:
        return 'coordinator';
      case UserRole.organizer:
        return 'organizer';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get label {
    switch (this) {
      case UserRole.participant:
        return 'شرکت‌کننده';
      case UserRole.venue:
        return 'کسب‌وکار میزبان';
      case UserRole.coordinator:
        return 'مدیر و هماهنگ‌کننده رویداد';
      case UserRole.organizer:
        return 'برگزارکننده / آژانس';
      case UserRole.admin:
        return 'ادمین پاتوق';
    }
  }

  static UserRole fromKey(String? value) {
    for (final role in UserRole.values) {
      if (role.key == value) return role;
    }
    return UserRole.participant;
  }
}
