import 'package:flutter/material.dart';
import 'package:patogh/data/mock_data.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/pages/category_events_page.dart';
import 'package:patogh/pages/event_detail_page.dart';
import 'package:patogh/pages/reservation_reminder_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/widgets/category_card.dart';
import 'package:patogh/widgets/event_banner.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  int selectedTab = 0;
  String query = '';

  final tabs = const ['دسته‌بندی', 'جدیدترین', 'تخفیف‌ها', 'رزرو من'];

  @override
  Widget build(BuildContext context) {
    final filteredEvents = events.where((event) {
      final q = query.trim();
      if (q.isEmpty) return true;
      return event.title.contains(q) ||
          event.subtitle.contains(q) ||
          event.area.contains(q);
    }).toList();

    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _header()),
                  SliverToBoxAdapter(child: _search()),
                  SliverToBoxAdapter(child: _storyRow()),
                  SliverToBoxAdapter(child: _location()),
                  SliverToBoxAdapter(child: _hero()),
                  SliverToBoxAdapter(child: _tabs()),
                  if (selectedTab == 0)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.83,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            category: category,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CategoryEventsPage(category: category),
                                ),
                              );
                            },
                          );
                        }, childCount: categories.length),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                      sliver: SliverList.separated(
                        itemCount: _eventsForSelectedTab(filteredEvents).length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final event = _eventsForSelectedTab(
                            filteredEvents,
                          )[index];
                          return EventBanner(
                            event: event,
                            compact: true,
                            onTap: () {
                              if (selectedTab == 3) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReservationReminderPage(event: event),
                                  ),
                                );
                              } else {
                                _openEvent(context, event);
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PatoghEvent> _eventsForSelectedTab(List<PatoghEvent> source) {
    if (selectedTab == 2) {
      return source.where((event) => event.price <= 240000).toList();
    }
    if (selectedTab == 3) {
      return source.where((event) {
        return appState.reservedIds.contains(event.id) ||
            appState.waitlistIds.contains(event.id);
      }).toList();
    }
    return source;
  }

  void _openEvent(BuildContext context, PatoghEvent event) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => EventDetailPage(event: event)));
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
      child: Row(
        children: [
          const Icon(Icons.dark_mode_outlined, size: 30, color: Colors.white),
          const Spacer(),
          const Text(
            'رزرو پاتوق',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      child: TextField(
        onChanged: (value) => setState(() => query = value),
        decoration: const InputDecoration(
          hintText: 'جست‌وجو',
          prefixIcon: Icon(Icons.search_rounded, size: 34),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _storyRow() {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final colors = [
            const Color(0xFFE3B39B),
            const Color(0xFFBA8368),
            const Color(0xFF98A8B7),
            const Color(0xFFCD8D75),
            const Color(0xFF728A7D),
            const Color(0xFF8D7FA6),
          ];
          return Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF8A2A), width: 2.4),
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              backgroundColor: colors[index],
              child: Icon(
                index.isEven ? Icons.person_rounded : Icons.groups_rounded,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _location() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, 14),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Color(0xFF2B8CC0)),
          SizedBox(width: 6),
          Text(
            'استان خراسان رضوی، شهر مشهد',
            style: TextStyle(color: Color(0xFF2B8CC0), fontSize: 13),
          ),
          Icon(Icons.chevron_left_rounded, color: Color(0xFF2B8CC0)),
        ],
      ),
    );
  }

  Widget _hero() {
    final featured = events.firstWhere((event) => event.id == 'breakfast-01');
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
      child: EventBanner(
        event: featured,
        compact: false,
        onTap: () => _openEvent(context, featured),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;
          final icons = [
            Icons.home_outlined,
            Icons.menu_book_rounded,
            Icons.discount_outlined,
            Icons.local_activity_outlined,
          ];
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: selected
                      ? const Border(
                          bottom: BorderSide(
                            color: Color(0xFF2B8CC0),
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      icons[index],
                      color: selected ? Colors.white : const Color(0xFF9C9C9C),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF9C9C9C),
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
