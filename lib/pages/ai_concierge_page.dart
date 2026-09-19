import 'package:flutter/material.dart';
import 'package:patogh/pages/event_detail_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AiConciergePage extends StatefulWidget {
  const AiConciergePage({super.key});

  @override
  State<AiConciergePage> createState() => _AiConciergePageState();
}

class _AiConciergePageState extends State<AiConciergePage> {
  final controller = TextEditingController(
    text: 'جمعه با خانواده در مشهد یک برنامه خلوت و مناسب کودک می‌خوام.',
  );
  bool searched = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = appState.events.take(3).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('دستیار پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B2819), Color(0xFF171717)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: PatoghTheme.orange,
                  size: 42,
                ),
                SizedBox(height: 10),
                Text(
                  'دنبال چه تجربه‌ای هستی؟',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  'به زبان خودت بگو؛ زمان، شهر، بودجه، همراهان و حال‌وهوای مدنظرت.',
                  style: TextStyle(color: Color(0xFFBBBBBB), height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'مثلاً امشب یک پاتوق آروم برای ۴ نفر...',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => setState(() => searched = true),
            icon: const Icon(Icons.search_rounded),
            label: const Text('پیشنهاد بده'),
          ),
          if (searched) ...[
            const SizedBox(height: 20),
            const Text(
              'پیشنهادهای اولیه',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...suggestions.map(
              (event) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailPage(event: event),
                      ),
                    ),
                    leading: Icon(event.icon, color: PatoghTheme.orange),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${event.area} • ${event.date} • ${appState.matchScore(event.tags)}٪ سازگاری',
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Text(
            'در Demo پیشنهادها محلی هستند؛ در Production این بخش به موتور جستجو و Matching متصل می‌شود.',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 10,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
