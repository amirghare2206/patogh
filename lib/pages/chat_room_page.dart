import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final String title;

  const ChatRoomPage({super.key, required this.title});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final controller = TextEditingController();
  final messages = <String>[
    'سلام به همه، خوش اومدین 👋',
    'محل نهایی فردا ظهر اعلام می‌شه.',
    'عالیه، ممنون 🙌',
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
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final mine = index == messages.length - 1;
                    return Align(
                      alignment: mine
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          color: mine
                              ? const Color(0xFF5A3B1D)
                              : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(messages[index]),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: const Color(0xFF141414),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: 'پیام...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setState(() {
                          messages.add(text);
                          controller.clear();
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A2A),
                      ),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
