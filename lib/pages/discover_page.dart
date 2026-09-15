import 'package:flutter/material.dart';
import 'package:patogh/data/places.dart';
import 'package:patogh/models/place.dart';
import 'package:patogh/pages/place_detail_page.dart';
import 'package:patogh/widgets/discover_place_card.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String searchText = '';
  String selectedCategory = 'همه';

  final List<String> categories = const [
    'همه',
    'تفریح',
    'گردشگری',
    'فرهنگی',
    'طبیعت',
  ];

  List<Place> get filteredPlaces {
    final search = searchText.trim();

    return allPlaces.where((place) {
      final matchesSearch =
          search.isEmpty ||
          place.title.contains(search) ||
          place.area.contains(search) ||
          place.category.contains(search);

      final matchesCategory =
          selectedCategory == 'همه' || place.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth > 700
            ? 700
            : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'کشف پاتوق‌ها',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'جای بعدی برای تفریح و گردش رو پیدا کن',
                        style: TextStyle(color: Color(0xFF777777)),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'نام مکان، منطقه یا دسته‌بندی...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Color(0xFF276A5B),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final selected = category == selectedCategory;

                            return ChoiceChip(
                              label: Text(category),
                              selected: selected,
                              showCheckmark: false,
                              selectedColor: const Color(0xFF276A5B),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: selected
                                    ? const Color(0xFF276A5B)
                                    : const Color(0xFFE4E4E4),
                              ),
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF444444),
                                fontWeight: FontWeight.w700,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredPlaces.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: Color(0xFFAAAAAA),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'پاتوقی پیدا نشد',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                          itemCount: filteredPlaces.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final place = filteredPlaces[index];

                            return DiscoverPlaceCard(
                              place: place,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PlaceDetailPage(place: place),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
