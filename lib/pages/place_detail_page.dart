import 'package:flutter/material.dart';
import 'package:patogh/models/place.dart';
import 'package:patogh/state/favorites.dart';
import 'package:patogh/widgets/patogh_info_box.dart';

class PlaceDetailPage extends StatelessWidget {
  final Place place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: favoritePlaces,
                        builder: (context, favorites, _) {
                          final isFavorite = favorites.contains(place.title);

                          return IconButton(
                            onPressed: () {
                              toggleFavorite(place.title);
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? Colors.red
                                  : const Color(0xFF333333),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: place.background,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(place.icon, size: 110, color: place.foreground),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    place.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 19,
                        color: Color(0xFF276A5B),
                      ),
                      const SizedBox(width: 5),
                      Text(place.area),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.star_rounded,
                        size: 19,
                        color: Color(0xFFFFB000),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.rating,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'درباره این پاتوق',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.9,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: PatoghInfoBox(
                          icon: Icons.category_rounded,
                          title: 'دسته‌بندی',
                          value: place.category,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PatoghInfoBox(
                          icon: Icons.near_me_rounded,
                          title: 'فاصله',
                          value: place.distance,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'مسیریابی را در مرحله بعد فعال می‌کنیم.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text(
                      'مسیریابی',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF276A5B),
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
