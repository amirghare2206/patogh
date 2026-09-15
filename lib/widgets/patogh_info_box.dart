import 'package:flutter/material.dart';

class PatoghInfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const PatoghInfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF276A5B)),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
