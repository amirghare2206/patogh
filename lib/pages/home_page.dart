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
import 'package:patogh/pages/profile_page.dart';
import 'package:patogh/pages/category_events_page.dart';
import 'package:patogh/models/patogh_category.dart';
import 'package:patogh/data/mock_data.dart' as mock;
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
                _serviceCategories(context),
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
          right: 0,
          top: 8,
          child: IconButton.filledTonal(
            tooltip: 'پروفایل من',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_rounded),
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

  Widget _serviceCategories(BuildContext context) {
    // ترتیب مطابق تصویر مرجع کاربر: از راست به چپ و ردیف‌به‌ردیف.
    const desiredOrder = <String>[
      'companion', 'volunteer', 'empathy',
      'story', 'sport', 'think',
      'travel', 'learn', 'work',
      'game', 'talk', 'intro',
    ];
    // Always retain the twelve baseline categories shown in the approved
    // reference; active server categories override their display metadata.
    final byId = <String, PatoghCategory>{
      for (final category in mock.categories) category.id: category,
      for (final category in appState.categories)
        if (category.isActive) category.id: category,
    };
    final ordered = <PatoghCategory>[];
    for (final id in desiredOrder) {
      final category = byId.remove(id);
      if (category != null) ordered.add(category);
    }
    // Custom categories remain available after the twelve reference categories.
    ordered.addAll(byId.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'پاتوق‌ها',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        const Text(
          'برای پیدا کردن جمع و تجربه‌ای که دوست داری، یک دسته را انتخاب کن.',
          textAlign: TextAlign.right,
          style: TextStyle(color: PatoghTheme.muted, fontSize: 11, height: 1.6),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ordered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final category = ordered[index];
            final color = category.accent;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryEventsPage(category: category),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: color.withAlpha(28),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(category.icon, color: color, size: 30),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF171717),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 8,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
