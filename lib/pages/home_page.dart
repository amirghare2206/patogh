import 'package:flutter/material.dart';
import 'package:patogh/data/places.dart';
import 'package:patogh/models/category_item.dart';
import 'package:patogh/pages/discover_page.dart';
import 'package:patogh/pages/favorites_page.dart';
import 'package:patogh/pages/profile_page.dart';
import 'package:patogh/widgets/featured_card.dart';
import 'package:patogh/widgets/nearby_card.dart';

class PatoghHomePage extends StatefulWidget {
  const PatoghHomePage({super.key});

  @override
  State<PatoghHomePage> createState() => _PatoghHomePageState();
}

class _PatoghHomePageState extends State<PatoghHomePage> {
  int selectedIndex = 0;

  final List<CategoryItem> categories = const [
    CategoryItem('تفریح', Icons.celebration_rounded),
    CategoryItem('گردشگری', Icons.landscape_rounded),
    CategoryItem('کافه', Icons.local_cafe_rounded),
    CategoryItem('ورزش', Icons.sports_soccer_rounded),
    CategoryItem('فرهنگی', Icons.theater_comedy_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _buildHome(),
            const DiscoverPage(),
            const FavoritesPage(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'کشف',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'علاقه‌مندی',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'پروفایل',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth > 700
            ? 700
            : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: maxWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topHeader(),
                  const SizedBox(height: 24),
                  _searchBox(),
                  const SizedBox(height: 22),
                  _heroCard(),
                  const SizedBox(height: 28),
                  _sectionHeader(title: 'دسته‌بندی‌ها', action: 'همه'),
                  const SizedBox(height: 14),
                  _categoryList(),
                  const SizedBox(height: 30),
                  _sectionHeader(
                    title: 'پاتوق‌های پیشنهادی',
                    action: 'مشاهده همه',
                  ),
                  const SizedBox(height: 14),
                  _featuredPlaces(),
                  const SizedBox(height: 30),
                  _sectionHeader(title: 'نزدیک شما', action: 'روی نقشه'),
                  const SizedBox(height: 14),
                  _nearbyPlaces(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE1EFEA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person_rounded, color: Color(0xFF276A5B)),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سلام 👋',
                style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
              ),
              SizedBox(height: 3),
              Text(
                'امروز کجا بریم؟',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202020),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Color(0xFF276A5B),
              ),
              SizedBox(width: 5),
              Text('مشهد', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 5),
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
          setState(() {
            selectedIndex = 1;
          });
        },
        decoration: const InputDecoration(
          hintText: 'دنبال چه پاتوقی می‌گردی؟',
          hintStyle: TextStyle(color: Color(0xFF9B9B9B)),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF276A5B)),
          suffixIcon: Icon(Icons.tune_rounded, color: Color(0xFF666666)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF276A5B), Color(0xFF3D8D78)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'پاتوق امروزت رو پیدا کن',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'بهترین مکان‌های تفریحی، فرهنگی و گردشگری شهر رو کشف کن.',
                  style: TextStyle(
                    color: Color(0xFFE4F3EE),
                    height: 1.7,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 17),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF276A5B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'شروع گشت‌وگذار',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 95,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({required String title, required String action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF202020),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF276A5B),
          ),
        ),
      ],
    );
  }

  Widget _categoryList() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = categories[index];

          return Container(
            width: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3EF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(item.icon, color: const Color(0xFF276A5B)),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _featuredPlaces() {
    return SizedBox(
      height: 235,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FeaturedCard(place: allPlaces[0]),
          const SizedBox(width: 14),
          FeaturedCard(place: allPlaces[1]),
          const SizedBox(width: 14),
          FeaturedCard(place: allPlaces[2]),
        ],
      ),
    );
  }

  Widget _nearbyPlaces() {
    return Column(
      children: [
        NearbyCard(place: allPlaces[3]),
        const SizedBox(height: 12),
        NearbyCard(place: allPlaces[1]),
        const SizedBox(height: 12),
        NearbyCard(place: allPlaces[0]),
      ],
    );
  }
}
