import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patogh/models/ecosystem_models.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/models/v8_models.dart';
import 'package:patogh/pages/campaigns_page.dart';
import 'package:patogh/pages/event_detail_page.dart';
import 'package:patogh/pages/iran_location_picker_page.dart';
import 'package:patogh/pages/memories_library_page.dart';
import 'package:patogh/pages/private_events_page.dart';
import 'package:patogh/pages/reservation_page.dart';
import 'package:patogh/pages/services_hub_page.dart';
import 'package:patogh/pages/stories_page.dart';
import 'package:patogh/pages/surprise_page.dart';
import 'package:patogh/pages/time_occasion_hub_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/widgets/event_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _bannerIndex = 0;
  String _eventFilter = 'all';

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
          final events = _filteredEvents();

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
                const SizedBox(height: 10),
                _eventFilters(),
                const SizedBox(height: 14),
                if (events.isEmpty)
                  _emptyEvents(context)
                else
                  ...events.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: EventCard(
                        event: event,
                        compact: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailPage(event: event),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Image.asset(
            'assets/branding/patogh_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.groups_rounded, color: PatoghTheme.orange),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'پاتوق',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
              ),
              Text(
                'آدم‌ها، تجربه‌ها و جمع‌های واقعی',
                style: TextStyle(color: PatoghTheme.muted, fontSize: 10.5),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ServicesHubPage())),
          icon: const Icon(Icons.apps_rounded),
          tooltip: 'سرویس‌های پاتوق',
        ),
        const SizedBox(width: 4),
        IconButton.filledTonal(
          onPressed: () => _pickLocation(context),
          icon: const Icon(Icons.location_on_rounded),
          tooltip: 'تغییر شهر',
        ),
      ],
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const StoriesPage())),
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              label: const Text('مشاهده همه'),
            ),
          ],
        ),
        const SizedBox(height: 7),
        if (appState.stories.isEmpty)
          Container(
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PatoghTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'هنوز استوری فعالی نیست.',
              style: TextStyle(color: PatoghTheme.muted),
            ),
          )
        else
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: appState.stories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final story = appState.stories[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StoriesPage()),
                  ),
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: PatoghTheme.brandGradient,
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
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          story.owner,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9.5),
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

  Widget _eventFilters() {
    final filters = <(String, String)>[
      ('all', 'همه'),
      ('latest', 'جدیدترین'),
      ('free', 'رایگان'),
      ('discount', 'تخفیف‌دار'),
      ('available', 'ظرفیت‌دار'),
      ...appState.categories
          .where((category) => category.isActive)
          .map((category) => ('category:${category.id}', category.title)),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final item = filters[index];
          return ChoiceChip(
            label: Text(item.$2),
            selected: _eventFilter == item.$1,
            onSelected: (_) => setState(() => _eventFilter = item.$1),
          );
        },
      ),
    );
  }

  List<PatoghEvent> _filteredEvents() {
    final events = List<PatoghEvent>.from(appState.events);
    switch (_eventFilter) {
      case 'free':
        return events.where((event) => event.finalPrice == 0).toList();
      case 'discount':
        return events.where((event) => event.discounted).toList();
      case 'available':
        return events.where((event) => !event.isFull).toList();
      case 'latest':
        return events.reversed.toList();
      default:
        if (_eventFilter.startsWith('category:')) {
          final categoryId = _eventFilter.substring('category:'.length);
          return events
              .where((event) => event.categoryId == categoryId)
              .toList();
        }
        return events;
    }
  }

  Widget _emptyEvents(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PatoghTheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 48,
            color: PatoghTheme.teal,
          ),
          const SizedBox(height: 10),
          const Text(
            'در این فیلتر رویدادی پیدا نشد.',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _eventFilter = 'all'),
            child: const Text('نمایش همه رویدادها'),
          ),
        ],
      ),
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
