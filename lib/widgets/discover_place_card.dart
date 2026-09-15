import 'package:flutter/material.dart';
import 'package:patogh/models/place.dart';

class DiscoverPlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const DiscoverPlaceCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDEDED)),
          ),
          child: Row(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: place.background,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(place.icon, size: 43, color: place.foreground),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${place.category} • ${place.area}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: Color(0xFFFFB000),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          place.rating,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 15),
                        const Icon(
                          Icons.near_me_rounded,
                          size: 15,
                          color: Color(0xFF276A5B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.distance,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: Color(0xFF999999)),
            ],
          ),
        ),
      ),
    );
  }
}
