import 'dart:async';
import 'package:patogh/pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:patogh/models/ecosystem_models.dart';
import 'package:patogh/models/v8_models.dart';
import 'package:patogh/pages/campaigns_page.dart';
import 'package:patogh/pages/iran_location_picker_page.dart';
import 'package:patogh/pages/memories_library_page.dart';
import 'package:patogh/pages/private_events_page.dart';
import 'package:patogh/pages/reservation_page.dart';
import 'package:patogh/pages/stories_page.dart';
import 'package:patogh/pages/surprise_page.dart';
import 'package:patogh/pages/time_occasion_hub_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/pages/event_detail_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final banners = _homeBanners;
      if (banners.length < 2) return;
      final next = (_bannerIndex + 1) % banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  List<BannerItem> get _homeBanners =>
      appState.banners.where((item) => item.placement == 'home').toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final banners = _homeBanners;

          return RefreshIndicator(
            onRefresh: () async {
              await appState.refreshSocialV12();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                _header(context),
                const SizedBox(height: 12),
                _location(context),
                const SizedBox(height: 12),
                _search(context),
                const SizedBox(height: 18),
                _stories(context),
                if (banners.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _bannerCarousel(context, banners),
                ],
              const SizedBox(height: 22),
_eventsHeader(context),
const SizedBox(height: 14),
_eventCategories(context),
const SizedBox(height: 28),
_personalizedSuggestions(context),
              ],
            ),
          );
        },
      ),
    );
  }

Widget _header(BuildContext context) {
  return SizedBox(
    height: 82,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/branding/patogh_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.groups_rounded,
                        color: PatoghTheme.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'پاتوق',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                'آدم‌ها، تجربه‌ها و جمع‌های واقعی',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PatoghTheme.muted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 0,
          top: 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_rounded),
                tooltip: 'اعلان‌ها',
              ),

              Positioned(
                right: 3,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: PatoghTheme.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _location(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _pickLocation(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [PatoghTheme.surface2, PatoghTheme.purple.withAlpha(35)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF3C426D)),
        ),
        child: Row(
          children: [
            const Icon(Icons.near_me_rounded, color: PatoghTheme.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${appState.selectedProvince} / ${appState.selectedCity}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }

  Widget _search(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ReservationPage())),
      child: const IgnorePointer(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'رویداد، تجربه یا دسته موردنظرت رو پیدا کن',
            prefixIcon: Icon(Icons.search_rounded),
            suffixIcon: Icon(Icons.tune_rounded),
          ),
        ),
      ),
    );
  }

 Widget _stories(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'استوری‌ها',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StoriesPage(),
                ),
              );
            },
            child: const Text('مشاهده همه'),
          ),
        ],
      ),
      const SizedBox(height: 8),

      SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: appState.stories.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            // استوری خود کاربر
            if (index == 0) {
              return InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StoriesPage(),
                    ),
                  );
                },
                child: SizedBox(
                  width: 74,
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PatoghTheme.purple.withAlpha(100),
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: PatoghTheme.surface2,
                              child: Icon(
                                Icons.person_rounded,
                                size: 31,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -1,
                            right: -1,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: PatoghTheme.orange,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'استوری من',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final story = appState.stories[index - 1];

            return InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StoriesPage(),
                  ),
                );
              },
              child: SizedBox(
                width: 74,
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: PatoghTheme.brandGradient,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundColor: PatoghTheme.surface2,
                          child: Text(
                            story.owner.trim().isEmpty
                                ? 'پ'
                                : String.fromCharCode(
                                    story.owner.trim().runes.first,
                                  ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      story.owner,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

  Widget _bannerCarousel(BuildContext context, List<BannerItem> banners) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(
                    color: PatoghTheme.surface,
                    child: InkWell(
                      onTap: () => _openBanner(context, banner),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _bannerImage(banner),
                          if (banner.sponsored)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(165),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'اسپانسرشده',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final selected = index == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: selected ? 22 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: selected ? PatoghTheme.orange : const Color(0xFF4A5075),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _bannerImage(BannerItem banner) {
    if (banner.imageAsset != null && banner.imageAsset!.isNotEmpty) {
      return Image.asset(
        banner.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _bannerFallback(banner),
      );
    }
    if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty) {
      return Image.network(
        banner.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _bannerFallback(banner),
      );
    }
    return _bannerFallback(banner);
  }

  Widget _bannerFallback(BannerItem banner) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(gradient: PatoghTheme.brandGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            banner.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(banner.subtitle),
        ],
      ),
    );
  }

  Widget _eventsHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رویدادها',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              Text(
                'اصل ماجرا از همین‌جا شروع می‌شود',
                style: TextStyle(color: PatoghTheme.muted, fontSize: 10.5),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ReservationPage())),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('جست‌وجو و فیلتر'),
        ),
      ],
    );
  }




 Widget _eventCategories(BuildContext context) {
  final categories = appState.categories
      .where((category) => category.isActive)
      .toList();

  if (categories.isEmpty) {
    return const SizedBox.shrink();
  }

  return SizedBox(
    height: 132,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final category = categories[index];

        return InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ReservationPage(),
              ),
            );
          },
          child: Container(
            width: 98,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  category.accent.withAlpha(70),
                  category.accent.withAlpha(22),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: category.accent.withAlpha(110),
              ),
              boxShadow: [
                BoxShadow(
                  color: category.accent.withAlpha(30),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: category.accent.withAlpha(45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: category.accent,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
Widget _personalizedSuggestions(BuildContext context) {
  final suggestions = [...appState.events]
    ..sort(
      (a, b) => appState
          .matchScore(b.tags)
          .compareTo(appState.matchScore(a.tags)),
    );

  final visibleSuggestions = suggestions.take(6).toList();
  final interests = appState.profile?.interests ?? const <String>[];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'پیشنهاد برای تو ✨',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  interests.isEmpty
                      ? 'چند پیشنهاد جذاب برای شروع'
                      : 'بر اساس چیزهایی که دوست داری',
                  style: const TextStyle(
                    color: PatoghTheme.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReservationPage(),
                ),
              );
            },
            child: const Text('همه رویدادها'),
          ),
        ],
      ),
      const SizedBox(height: 12),

      if (visibleSuggestions.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: PatoghTheme.brandGradient,
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.explore_rounded,
                color: Colors.white,
                size: 34,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'رویدادهای تازه پاتوق به‌زودی اینجا ظاهر می‌شوند.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        )
      else
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visibleSuggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final event = visibleSuggestions[index];
              final score = appState.matchScore(event.tags);

              return InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailPage(event: event),
                    ),
                  );
                },
                child: Container(
                  width: 205,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: event.gradient,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(28),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(32),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              event.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '$score٪ تطابق',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white70,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${event.date} • ${event.time}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white70,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    ],
  );
}

  void _openBanner(BuildContext context, BannerItem banner) {
    final page = switch (banner.id) {
      'banner-discover' => const ReservationPage(),
      'banner-invites' => const PrivateEventsPage(),
      'banner-memories' => const MemoriesLibraryPage(),
      'banner-surprise' => const SurprisePage(),
      'banner-calendar' => const TimeOccasionHubPage(),
      _ => const CampaignsPage(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _pickLocation(BuildContext context) async {
    final choice = await Navigator.of(context).push<LocationChoice>(
      MaterialPageRoute(
        builder: (_) => IranLocationPickerPage(
          initialProvince: appState.selectedProvince,
          initialCity: appState.selectedCity,
        ),
      ),
    );
    if (choice != null) {
      await appState.setSelectedLocation(choice.province, choice.city);
    }
  }
}
