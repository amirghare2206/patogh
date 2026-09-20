enum EngagementXpType { discovery, social, culture, contribution }

extension EngagementXpTypeX on EngagementXpType {
  String get label {
    switch (this) {
      case EngagementXpType.discovery:
        return 'اکتشاف';
      case EngagementXpType.social:
        return 'اجتماعی';
      case EngagementXpType.culture:
        return 'فرهنگی';
      case EngagementXpType.contribution:
        return 'مشارکت';
    }
  }
}

class PatoghQuest {
  final String id;
  final String title;
  final String description;
  final String category;
  final int progress;
  final int target;
  final int rewardXp;
  final bool completed;

  const PatoghQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.progress,
    required this.target,
    required this.rewardXp,
    this.completed = false,
  });

  double get ratio => target == 0 ? 0 : (progress / target).clamp(0, 1);

  PatoghQuest copyWith({int? progress, bool? completed}) {
    return PatoghQuest(
      id: id,
      title: title,
      description: description,
      category: category,
      progress: progress ?? this.progress,
      target: target,
      rewardXp: rewardXp,
      completed: completed ?? this.completed,
    );
  }
}

class PassportStamp {
  final String id;
  final String province;
  final String city;
  final String title;
  final String subtitle;
  final bool unlocked;

  const PassportStamp({
    required this.id,
    required this.province,
    required this.city,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  PassportStamp copyWith({bool? unlocked}) => PassportStamp(
    id: id,
    province: province,
    city: city,
    title: title,
    subtitle: subtitle,
    unlocked: unlocked ?? this.unlocked,
  );
}

enum PlaceStoryType {
  geography,
  history,
  localLegend,
  people,
  food,
  patoghMemory,
  liveOpportunity,
}

extension PlaceStoryTypeX on PlaceStoryType {
  String get label {
    switch (this) {
      case PlaceStoryType.geography:
        return 'جغرافیا';
      case PlaceStoryType.history:
        return 'تاریخ';
      case PlaceStoryType.localLegend:
        return 'روایت محلی';
      case PlaceStoryType.people:
        return 'آدم‌های اینجا';
      case PlaceStoryType.food:
        return 'خوراک و فرهنگ';
      case PlaceStoryType.patoghMemory:
        return 'خاطره پاتوق';
      case PlaceStoryType.liveOpportunity:
        return 'فرصت زنده';
    }
  }
}

class PlaceStory {
  final String id;
  final String title;
  final String placeLabel;
  final PlaceStoryType type;
  final String durationLabel;
  final String summary;
  final String storyText;
  final String authorLabel;
  final bool verified;
  final int cultureXp;

  const PlaceStory({
    required this.id,
    required this.title,
    required this.placeLabel,
    required this.type,
    required this.durationLabel,
    required this.summary,
    required this.storyText,
    required this.authorLabel,
    required this.verified,
    this.cultureXp = 20,
  });
}

class RouteExperience {
  final String id;
  final String origin;
  final String destination;
  final String distanceLabel;
  final List<String> corridor;
  final List<PlaceStory> stories;

  const RouteExperience({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceLabel,
    required this.corridor,
    required this.stories,
  });
}

class StoryChapter {
  final String title;
  final String prompt;

  const StoryChapter({required this.title, required this.prompt});
}

class EventStoryBlueprint {
  final String id;
  final String eventTitle;
  final String promise;
  final List<StoryChapter> chapters;
  final String memoryPrompt;

  const EventStoryBlueprint({
    required this.id,
    required this.eventTitle,
    required this.promise,
    required this.chapters,
    required this.memoryPrompt,
  });
}

class LocalStorySubmission {
  final String id;
  final String author;
  final String placeLabel;
  final String title;
  final String text;
  final String status;

  const LocalStorySubmission({
    required this.id,
    required this.author,
    required this.placeLabel,
    required this.title,
    required this.text,
    this.status = 'pending',
  });

  LocalStorySubmission copyWith({String? status}) => LocalStorySubmission(
    id: id,
    author: author,
    placeLabel: placeLabel,
    title: title,
    text: text,
    status: status ?? this.status,
  );
}
