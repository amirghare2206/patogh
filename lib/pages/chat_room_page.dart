import 'package:flutter/material.dart';
import 'package:patogh/services/media_service.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/widgets/media_attachment_strip.dart';
import 'package:patogh/widgets/media_picker_panel.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String title;
  const ChatRoomPage({super.key, required this.roomId, required this.title});
  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final controller = TextEditingController();
  final media = <SelectedMedia>[];
  bool showPicker = false;
  @override
  void initState() {
    super.initState();
    appState.startChatRoom(widget.roomId);
  }

  @override
  void dispose() {
    controller.dispose();
    appState.stopChatRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_forward_rounded),
      ),
    ),
    body: AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final messages = appState.roomMessages(widget.roomId);
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return GestureDetector(
                    onLongPress: msg.id.isEmpty
                        ? null
                        : () async {
                            await appState.reportContent(
                              targetType: 'chat_message',
                              targetId: msg.id,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('گزارش ثبت شد.')),
                              );
                            }
                          },
                    child: Align(
                      alignment: msg.mine
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: msg.mine
                              ? const Color(0xFF5A3B1D)
                              : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (msg.text.isNotEmpty) Text(msg.text),
                            if (msg.media.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              MediaAttachmentStrip(
                                media: msg.media,
                                height: 110,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              msg.time,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (showPicker)
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                color: const Color(0xFF111111),
                child: MediaPickerPanel(
                  items: media,
                  postOrStory: false,
                  allowAudio: true,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF141414),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => showPicker = !showPicker),
                    icon: const Icon(Icons.attach_file_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'پیام...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty && media.isEmpty) return;
                      final sending = List<SelectedMedia>.from(media);
                      await appState.sendMessage(
                        widget.roomId,
                        text,
                        media: sending,
                      );
                      controller.clear();
                      if (mounted) {
                        setState(() {
                          media.clear();
                          showPicker = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
