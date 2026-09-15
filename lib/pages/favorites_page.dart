import 'package:flutter/material.dart';
import 'package:patogh/data/places.dart';
import 'package:patogh/pages/place_detail_page.dart';
import 'package:patogh/state/favorites.dart';
import 'package:patogh/widgets/discover_place_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoritePlaces,
      builder: (context, favorites, _) {
        final places = allPlaces
            .where((place) => favorites.contains(place.title))
            .toList();

        if (places.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 70,
                    color: Color(0xFFAAAAAA),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'هنوز پاتوقی ذخیره نکردی',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'از صفحه کشف وارد یک پاتوق شو و روی قلب بزن.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Text(
                    'علاقه‌مندی‌ها',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                    itemCount: places.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final place = places[index];

                      return DiscoverPlaceCard(
                        place: place,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailPage(place: place),
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
