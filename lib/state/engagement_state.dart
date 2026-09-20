import 'package:flutter/foundation.dart';
import 'package:patogh/models/engagement_models.dart';

class EngagementState extends ChangeNotifier {
  int discoveryXp = 270;
  int socialXp = 180;
  int cultureXp = 220;
  int contributionXp = 90;
  int socialRhythmMonths = 4;
  int attendanceStreak = 6;
  bool routeSessionActive = false;
  String? activeRouteId;

  final Set<String> listenedStoryIds = <String>{};

  final List<PatoghQuest> quests = [
    const PatoghQuest(
      id: 'quest-autumn',
      title: 'چالش پاییزگردی',
      description: 'در سه تجربه فضای باز یا سفر کوتاه شرکت کن.',
      category: 'اکتشاف',
      progress: 1,
      target: 3,
      rewardXp: 120,
    ),
    const PatoghQuest(
      id: 'quest-culture',
      title: 'قصه‌های شهر من',
      description: 'پنج روایت محلی یا فرهنگی پاتوق را کامل بشنو.',
      category: 'فرهنگ',
      progress: 2,
      target: 5,
      rewardXp: 100,
    ),
    const PatoghQuest(
      id: 'quest-circle',
      title: 'با حلقه‌ات پاتوق برو',
      description: 'در یک رویداد همراه حداقل دو نفر از حلقه شرکت کن.',
      category: 'اجتماعی',
      progress: 0,
      target: 1,
      rewardXp: 80,
    ),
  ];

  final List<PassportStamp> stamps = [
    const PassportStamp(
      id: 'stamp-mashhad',
      province: 'خراسان رضوی',
      city: 'مشهد',
      title: 'مشهدگرد',
      subtitle: 'اولین تجربه شهری ثبت‌شده',
      unlocked: true,
    ),
    const PassportStamp(
      id: 'stamp-nishabur',
      province: 'خراسان رضوی',
      city: 'نیشابور',
      title: 'رد پای خیام',
      subtitle: 'روایت و تجربه فرهنگی نیشابور',
      unlocked: false,
    ),
    const PassportStamp(
      id: 'stamp-yazd',
      province: 'یزد',
      city: 'یزد',
      title: 'کوچه‌های بادگیر',
      subtitle: 'کشف یک تجربه محلی در یزد',
      unlocked: false,
    ),
  ];

  final List<RouteExperience> routes = const [
    RouteExperience(
      id: 'route-mashhad-yazd',
      origin: 'مشهد',
      destination: 'یزد',
      distanceLabel: 'مسیر بین‌شهری نمونه',
      corridor: ['مشهد', 'تربت‌حیدریه', 'طبس', 'میبد', 'یزد'],
      stories: [
        PlaceStory(
          id: 'story-torbat',
          title: 'زعفران، قنات و راه‌های قدیمی',
          placeLabel: 'تربت‌حیدریه',
          type: PlaceStoryType.geography,
          durationLabel: '۲ دقیقه',
          summary: 'یک روایت کوتاه از جغرافیا و اقتصاد محلی مسیر.',
          storyText: 'این بخش از مسیر نمونه‌ای برای تجربه صوتی مکان‌محور پاتوق است؛ در نسخه Production متن و صوت از منبع تأییدشده دریافت می‌شود.',
          authorLabel: 'تحریریه پاتوق',
          verified: true,
        ),
        PlaceStory(
          id: 'story-tabas',
          title: 'طبس؛ دروازه کویر و قصه آب',
          placeLabel: 'طبس',
          type: PlaceStoryType.history,
          durationLabel: '۳ دقیقه',
          summary: 'روایتی درباره کویر، آب و مسیرهای تاریخی.',
          storyText: 'قصه این نقطه در نسخه واقعی با داده منبع‌دار، روایت محلی و نسخه صوتی قابل دانلود تکمیل می‌شود.',
          authorLabel: 'پاتوق + روایت محلی',
          verified: true,
        ),
        PlaceStory(
          id: 'story-meybod',
          title: 'ایستگاه تجربه؛ میبد',
          placeLabel: 'میبد',
          type: PlaceStoryType.liveOpportunity,
          durationLabel: 'فرصت زنده',
          summary: 'یک میزبان محلی و تجربه فرهنگی در مسیر شما.',
          storyText: 'در نسخه Production این کارت از رویدادها، ظرفیت میزبان و زمان واقعی مسیر تولید می‌شود.',
          authorLabel: 'موتور فرصت پاتوق',
          verified: true,
          cultureXp: 10,
        ),
      ],
    ),
    RouteExperience(
      id: 'route-tehran-shiraz',
      origin: 'تهران',
      destination: 'شیراز',
      distanceLabel: 'مسیر بین‌شهری نمونه',
      corridor: ['تهران', 'قم', 'کاشان', 'اصفهان', 'آباده', 'شیراز'],
      stories: [
        PlaceStory(
          id: 'story-kashan',
          title: 'خانه، باغ و عطر گلاب',
          placeLabel: 'کاشان',
          type: PlaceStoryType.localLegend,
          durationLabel: '۲ دقیقه',
          summary: 'روایت محلی و فرهنگی یک توقف میان‌راهی.',
          storyText: 'این روایت نمونه است و برای Production باید منبع، گوینده و وضعیت تأیید محتوا ثبت شود.',
          authorLabel: 'راوی محلی نمونه',
          verified: false,
        ),
      ],
    ),
  ];

  final List<EventStoryBlueprint> blueprints = const [
    EventStoryBlueprint(
      id: 'blueprint-dinner',
      eventTitle: 'قرار شام پاتوق',
      promise: 'چند آدم تازه، یک میز کوچک و دو ساعت گفت‌وگوی واقعی.',
      chapters: [
        StoryChapter(
          title: 'ورود',
          prompt: 'هر نفر با یک سؤال ساده خودش را معرفی می‌کند.',
        ),
        StoryChapter(title: 'یخ‌شکن', prompt: 'یک بازی کوتاه برای شروع تعامل.'),
        StoryChapter(
          title: 'گفت‌وگوی اصلی',
          prompt: 'گفت‌وگو حول موضوع مشترک گروه.',
        ),
        StoryChapter(
          title: 'یادگاری',
          prompt: 'عکس گروهی یا یک جمله از هر نفر برای کپسول خاطره.',
        ),
      ],
      memoryPrompt: 'از این شب چه چیزی را دوست داری یک سال بعد دوباره ببینی؟',
    ),
  ];

  final List<LocalStorySubmission> submissions = [
    const LocalStorySubmission(
      id: 'submission-1',
      author: 'راوی محلی نمونه',
      placeLabel: 'نیشابور',
      title: 'قصه یک کوچه قدیمی',
      text: 'نمونه روایت کاربرمحور برای بررسی و تأیید تحریریه پاتوق.',
    ),
  ];

  int get totalXp => discoveryXp + socialXp + cultureXp + contributionXp;

  Future<void> listenToStory(PlaceStory story) async {
    if (listenedStoryIds.add(story.id)) {
      cultureXp += story.cultureXp;
      _advanceQuest('quest-culture');
      notifyListeners();
    }
  }

  Future<void> startRoute(String routeId) async {
    routeSessionActive = true;
    activeRouteId = routeId;
    notifyListeners();
  }

  Future<void> endRoute() async {
    routeSessionActive = false;
    activeRouteId = null;
    notifyListeners();
  }

  Future<void> unlockStamp(String stampId) async {
    final index = stamps.indexWhere((stamp) => stamp.id == stampId);
    if (index == -1 || stamps[index].unlocked) return;
    stamps[index] = stamps[index].copyWith(unlocked: true);
    discoveryXp += 80;
    notifyListeners();
  }

  Future<void> completeQuestDemo(String questId) async {
    final index = quests.indexWhere((quest) => quest.id == questId);
    if (index == -1 || quests[index].completed) return;
    quests[index] = quests[index].copyWith(
      progress: quests[index].target,
      completed: true,
    );
    discoveryXp += quests[index].rewardXp;
    notifyListeners();
  }

  Future<void> submitLocalStory({
    required String author,
    required String placeLabel,
    required String title,
    required String text,
  }) async {
    submissions.insert(
      0,
      LocalStorySubmission(
        id: 'submission-${DateTime.now().microsecondsSinceEpoch}',
        author: author,
        placeLabel: placeLabel,
        title: title,
        text: text,
      ),
    );
    contributionXp += 30;
    notifyListeners();
  }

  Future<void> reviewSubmission(String id, bool approve) async {
    final index = submissions.indexWhere((item) => item.id == id);
    if (index == -1) return;
    submissions[index] = submissions[index].copyWith(
      status: approve ? 'approved' : 'rejected',
    );
    notifyListeners();
  }

  void _advanceQuest(String questId) {
    final index = quests.indexWhere((quest) => quest.id == questId);
    if (index == -1 || quests[index].completed) return;
    final next = (quests[index].progress + 1).clamp(0, quests[index].target);
    final done = next >= quests[index].target;
    quests[index] = quests[index].copyWith(progress: next, completed: done);
    if (done) {
      cultureXp += quests[index].rewardXp;
    }
  }
}

final EngagementState engagementState = EngagementState();
