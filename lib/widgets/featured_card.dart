import 'package:flutter/material.dart';
import 'package:patogh/models/place.dart';
import 'package:patogh/state/favorites.dart';

class FeaturedCard extends StatelessWidget {
  final Place place;

  const FeaturedCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 135,
            decoration: BoxDecoration(
              color: place.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(23),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(place.icon, size: 70, color: place.foreground),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: favoritePlaces,
                    builder: (context, favorites, _) {
                      final isFavorite = favorites.contains(place.title);

                      return Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            toggleFavorite(place.title);
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 19,
                            color: isFavorite ? Colors.red : Colors.black87,
                          ),
                        ),
                      );
                    },
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
                  place.title,
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
                        place.category,
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
                      place.rating,
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
