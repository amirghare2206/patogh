import 'package:flutter/material.dart';
import 'package:patogh/models/place.dart';

class NearbyCard extends StatelessWidget {
  final Place place;

  const NearbyCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: place.background,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(place.icon, color: place.foreground, size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${place.category} • ${place.area}',
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
                place.distance,
                style: const TextStyle(color: Color(0xFF777777), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
