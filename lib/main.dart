import 'package:flutter/material.dart';

void main() {
  runApp(const PatoghApp());
}

class PatoghApp extends StatelessWidget {
  const PatoghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پاتوق',
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF276A5B),
          brightness: Brightness.light,
        ),
      ),
      home: const PatoghHomePage(),
    );
  }
}

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
            const _SimplePage(
              icon: Icons.explore_rounded,
              title: 'کشف پاتوق‌ها',
              subtitle: 'این بخش در مرحله بعد ساخته می‌شود.',
            ),
            const _SimplePage(
              icon: Icons.favorite_rounded,
              title: 'علاقه‌مندی‌ها',
              subtitle: 'پاتوق‌های مورد علاقه‌ات اینجا قرار می‌گیرند.',
            ),
            const _SimplePage(
              icon: Icons.person_rounded,
              title: 'پروفایل',
              subtitle: 'اطلاعات حساب کاربری و تنظیمات.',
            ),
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
        final double maxWidth =
            constraints.maxWidth > 700 ? 700 : constraints.maxWidth;

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
                  _sectionHeader(
                    title: 'دسته‌بندی‌ها',
                    action: 'همه',
                  ),
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
                  _sectionHeader(
                    title: 'نزدیک شما',
                    action: 'روی نقشه',
                  ),
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
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xFF276A5B),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سلام 👋',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF777777),
                ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Color(0xFF276A5B),
              ),
              SizedBox(width: 5),
              Text(
                'مشهد',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
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
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'دنبال چه پاتوقی می‌گردی؟',
          hintStyle: TextStyle(
            color: Color(0xFF9B9B9B),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF276A5B),
          ),
          suffixIcon: Icon(
            Icons.tune_rounded,
            color: Color(0xFF666666),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
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
          colors: [
            Color(0xFF276A5B),
            Color(0xFF3D8D78),
          ],
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
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
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

  Widget _sectionHeader({
    required String title,
    required String action,
  }) {
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
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = categories[index];

          return Container(
            width: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFEEEEEE),
              ),
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
                  child: Icon(
                    item.icon,
                    color: const Color(0xFF276A5B),
                  ),
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
        children: const [
          _FeaturedCard(
            title: 'بوستان کوهسنگی',
            category: 'گردشگری و تفریح',
            rating: '۴.۸',
            icon: Icons.landscape_rounded,
            background: Color(0xFFE5F2EE),
            foreground: Color(0xFF276A5B),
          ),
          SizedBox(width: 14),
          _FeaturedCard(
            title: 'پارک ملت',
            category: 'تفریح و ورزش',
            rating: '۴.۷',
            icon: Icons.park_rounded,
            background: Color(0xFFECEAF8),
            foreground: Color(0xFF57508A),
          ),
          SizedBox(width: 14),
          _FeaturedCard(
            title: 'طرقبه',
            category: 'طبیعت و گردشگری',
            rating: '۴.۹',
            icon: Icons.forest_rounded,
            background: Color(0xFFF5EEE3),
            foreground: Color(0xFF855E3E),
          ),
        ],
      ),
    );
  }

  Widget _nearbyPlaces() {
    return const Column(
      children: [
        _NearbyCard(
          title: 'باغ ملی',
          subtitle: 'فرهنگی • فضای سبز',
          distance: '۱.۲ کیلومتر',
          icon: Icons.park_outlined,
        ),
        SizedBox(height: 12),
        _NearbyCard(
          title: 'بوستان ملت',
          subtitle: 'تفریحی • ورزشی',
          distance: '۲.۴ کیلومتر',
          icon: Icons.directions_run_rounded,
        ),
        SizedBox(height: 12),
        _NearbyCard(
          title: 'کوهسنگی',
          subtitle: 'گردشگری • طبیعت',
          distance: '۳.۱ کیلومتر',
          icon: Icons.landscape_outlined,
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String category;
  final String rating;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _FeaturedCard({
    required this.title,
    required this.category,
    required this.rating,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 135,
            decoration: BoxDecoration(
              color: background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 70,
                    color: foreground,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 17,
                      color: Color(0xFFFFB000),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String distance;
  final IconData icon;

  const _NearbyCard({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3EF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF276A5B),
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.near_me_rounded,
                size: 18,
                color: Color(0xFF276A5B),
              ),
              const SizedBox(height: 5),
              Text(
                distance,
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SimplePage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3EF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                size: 50,
                color: const Color(0xFF276A5B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF777777),
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final IconData icon;

  const CategoryItem(this.title, this.icon);
}