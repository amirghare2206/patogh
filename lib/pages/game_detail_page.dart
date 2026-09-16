import 'package:flutter/material.dart';

class GameDetailPage extends StatefulWidget {
  final String title;
  final IconData icon;

  const GameDetailPage({super.key, required this.title, required this.icon});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  int index = 0;

  final prompts = const [
    'اگر قرار بود یک مهارت رو فوری یاد بگیری، چی انتخاب می‌کردی؟',
    'آخرین چیزی که واقعاً خندوندت چی بود؟',
    'یک سفر کوتاه ترجیح می‌دی یا یک شب دورهمی طولانی؟',
    'چه چیزی باعث می‌شه از یک جمع حس خوبی بگیری؟',
    'اگر امشب یک فیلم جمعی ببینیم، چه ژانری انتخاب می‌کنی؟',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Icon(widget.icon, size: 72, color: const Color(0xFFFF8A2A)),
                const SizedBox(height: 20),
                Text(
                  prompts[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    setState(() => index = (index + 1) % prompts.length);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A2A),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: const Text('سؤال بعدی'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
