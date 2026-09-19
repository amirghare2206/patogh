import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/pages/category_events_page.dart';
import 'package:patogh/pages/event_detail_page.dart';
import 'package:patogh/pages/reservation_reminder_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/widgets/category_card.dart';
import 'package:patogh/widgets/event_card.dart';

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
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              SliverToBoxAdapter(child: _search()),
              SliverToBoxAdapter(child: _location()),
              SliverToBoxAdapter(child: _hero()),
              SliverToBoxAdapter(child: _tabs()),
              if (selectedTab == 0) _categories() else _eventList(),
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
      child: Row(
        children: [
          const Icon(Icons.dark_mode_outlined, size: 30),
          const Spacer(),
          Column(
            children: [
              const Text(
                'رزرو پاتوق',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
              ),
              if (appState.profile != null)
                Text(
                  'سلام ${appState.profile!.name}',
                  style: const TextStyle(
                    color: Color(0xFF9F9F9F),
                    fontSize: 10,
                  ),
                ),
            ],
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

  Widget _location() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: PatoghTheme.blue),
          const SizedBox(width: 6),
          Text(
            'شهر ${appState.profile?.city ?? 'مشهد'}',
            style: const TextStyle(color: PatoghTheme.blue, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final featured = appState.events.length > 1
        ? appState.events[1]
        : appState.events.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
      child: EventCard(event: featured, onTap: () => _openEvent(featured)),
    );
  }

  Widget _tabs() {
    final icons = const [
      Icons.home_outlined,
      Icons.menu_book_rounded,
      Icons.discount_outlined,
      Icons.local_activity_outlined,
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: selected
                      ? const Border(
                          bottom: BorderSide(color: PatoghTheme.blue, width: 3),
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

  Widget _categories() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final activeCategories = appState.categories
                .where((category) => category.isActive)
                .toList();
            final category = activeCategories[index];
            return CategoryCard(
              category: category,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryEventsPage(category: category),
                  ),
                );
              },
            );
          },
          childCount: appState.categories
              .where((category) => category.isActive)
              .length,
        ),
      ),
    );
  }

  Widget _eventList() {
    final source = _filteredEvents();

    if (source.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'موردی پیدا نشد.',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final event = source[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: _reservationItem(event),
          );
        }, childCount: source.length),
      ),
    );
  }

  Widget _reservationItem(PatoghEvent event) {
    if (selectedTab == 3) {
      final reserved = appState.reservedIds.contains(event.id);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EventCard(
            event: event,
            compact: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReservationReminderPage(event: event),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: reserved
                  ? const Color(0xFF153126)
                  : const Color(0xFF3A2B18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              reserved ? 'رزرو تأیید شده' : 'در لیست انتظار',
              style: TextStyle(
                color: reserved
                    ? const Color(0xFF8DDFB9)
                    : const Color(0xFFFFC36B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
    }

    return EventCard(
      event: event,
      compact: true,
      onTap: () => _openEvent(event),
    );
  }

  List<PatoghEvent> _filteredEvents() {
    var list = appState.events.where((event) {
      final q = query.trim();
      if (q.isEmpty) return true;
      return event.title.contains(q) ||
          event.subtitle.contains(q) ||
          event.area.contains(q);
    }).toList();

    if (selectedTab == 2) {
      list = list.where((event) => event.discounted).toList();
    }

    if (selectedTab == 3) {
      list = list
          .where(
            (event) =>
                appState.reservedIds.contains(event.id) ||
                appState.waitlistIds.contains(event.id),
          )
          .toList();
    }

    return list;
  }

  void _openEvent(PatoghEvent event) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => EventDetailPage(event: event)));
  }
}
