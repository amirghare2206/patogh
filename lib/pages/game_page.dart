import 'package:flutter/material.dart';
import 'package:patogh/pages/game_detail_page.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = const [
      ('یخ‌شکن ۶۰ ثانیه‌ای', 'شروع سریع گفتگو', Icons.timer_rounded),
      ('دو حقیقت، یک دروغ', 'بازی آشنایی گروهی', Icons.psychology_alt_rounded),
      ('کارت گفت‌وگو', 'سؤال‌های عمیق‌تر', Icons.style_rounded),
      ('انتخاب سخت', 'دو گزینه‌ای‌های بامزه', Icons.swap_horiz_rounded),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'بازی‌های پاتوق',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'برای شروع راحت‌تر گفتگو و گرم شدن جمع',
            style: TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 18),
          ...games.map(
            (game) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GameDetailPage(title: game.$1, icon: game.$3),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2A2A2A),
                    child: Icon(game.$3, color: const Color(0xFFFF8A2A)),
                  ),
                  title: Text(
                    game.$1,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    game.$2,
                    style: const TextStyle(color: Color(0xFFB8B8B8)),
                  ),
                  trailing: const Icon(Icons.chevron_left_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
