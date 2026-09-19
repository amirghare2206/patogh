import 'package:patogh/models/user_role.dart';

enum SocialLinkVisibility { public, sharedEvent, circle, mutual, private }

extension SocialLinkVisibilityX on SocialLinkVisibility {
  String get label {
    switch (this) {
      case SocialLinkVisibility.public:
        return 'عمومی';
      case SocialLinkVisibility.sharedEvent:
        return 'هم‌رویدادی‌ها';
      case SocialLinkVisibility.circle:
        return 'دوستان و خانواده';
      case SocialLinkVisibility.mutual:
        return 'ارتباط دوطرفه';
      case SocialLinkVisibility.private:
        return 'فقط خودم';
    }
  }
}

class SocialLinkItem {
  final String id;
  final String platform;
  final String handleOrUrl;
  final SocialLinkVisibility visibility;

  const SocialLinkItem({
    required this.id,
    required this.platform,
    required this.handleOrUrl,
    required this.visibility,
  });

  SocialLinkItem copyWith({SocialLinkVisibility? visibility}) {
    return SocialLinkItem(
      id: id,
      platform: platform,
      handleOrUrl: handleOrUrl,
      visibility: visibility ?? this.visibility,
    );
  }
}

class CircleMember {
  final String id;
  final String name;
  final String relation;
  final bool accepted;
  final bool notifyOnEventJoin;

  const CircleMember({
    required this.id,
    required this.name,
    required this.relation,
    this.accepted = false,
    this.notifyOnEventJoin = false,
  });

  CircleMember copyWith({bool? accepted, bool? notifyOnEventJoin}) {
    return CircleMember(
      id: id,
      name: name,
      relation: relation,
      accepted: accepted ?? this.accepted,
      notifyOnEventJoin: notifyOnEventJoin ?? this.notifyOnEventJoin,
    );
  }
}

class RoleMembership {
  final UserRole role;
  final String status;

  const RoleMembership({required this.role, required this.status});
}

class FamiliarFace {
  final String name;
  final int sharedEvents;
  final bool mutualReconnect;

  const FamiliarFace({
    required this.name,
    required this.sharedEvents,
    this.mutualReconnect = false,
  });
}

class EventTimeOption {
  final String id;
  final String label;
  final int yes;
  final int maybe;

  const EventTimeOption({
    required this.id,
    required this.label,
    required this.yes,
    required this.maybe,
  });
}

class DynamicRegistrationQuestion {
  final String id;
  final String label;
  final String type;
  final bool required;

  const DynamicRegistrationQuestion({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
  });
}

class MembershipClub {
  final String id;
  final String title;
  final String subtitle;
  final int monthlyPrice;
  final int members;
  final bool joined;

  const MembershipClub({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.monthlyPrice,
    required this.members,
    this.joined = false,
  });

  MembershipClub copyWith({bool? joined, int? members}) {
    return MembershipClub(
      id: id,
      title: title,
      subtitle: subtitle,
      monthlyPrice: monthlyPrice,
      members: members ?? this.members,
      joined: joined ?? this.joined,
    );
  }
}

class EventAlbumEntry {
  final String id;
  final String eventTitle;
  final String author;
  final String caption;
  final bool verifiedAttendance;

  const EventAlbumEntry({
    required this.id,
    required this.eventTitle,
    required this.author,
    required this.caption,
    this.verifiedAttendance = true,
  });
}

class LocationChoice {
  final String province;
  final String city;

  const LocationChoice({required this.province, required this.city});

  @override
  String toString() => '$province / $city';
}
