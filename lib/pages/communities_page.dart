import 'package:flutter/material.dart';
import 'package:patogh/models/community.dart';
import 'package:patogh/pages/chat_room_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'گروه‌ها و کانال‌ها',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _createCommunity(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ساخت'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'همه کاربران می‌توانند گروه یا کانال بسازند و تعامل را بعد از رویداد ادامه دهند.',
              style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
            ),
            const SizedBox(height: 18),
            ...appState.communities.map(
              (community) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: community.joined
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoomPage(
                                  roomId: community.id,
                                  title: community.title,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF2A2A2A),
                            child: Icon(
                              community.type == CommunityType.group
                                  ? Icons.groups_rounded
                                  : Icons.campaign_rounded,
                              color: PatoghTheme.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  community.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  community.description,
                                  style: const TextStyle(
                                    color: Color(0xFFAAAAAA),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${community.members} عضو • ${community.type == CommunityType.group ? 'گروه' : 'کانال'}',
                                  style: const TextStyle(
                                    color: Color(0xFF7F7F7F),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => appState.toggleCommunityMembership(
                              community.id,
                            ),
                            child: Text(
                              community.joined ? 'عضو هستی' : 'عضویت',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCommunity(BuildContext context) async {
    final title = TextEditingController();
    final description = TextEditingController();
    var type = CommunityType.group;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('ساخت گروه یا کانال'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'نام'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'توضیح'),
              ),
              const SizedBox(height: 10),
              SegmentedButton<CommunityType>(
                segments: const [
                  ButtonSegment(
                    value: CommunityType.group,
                    label: Text('گروه'),
                    icon: Icon(Icons.groups_rounded),
                  ),
                  ButtonSegment(
                    value: CommunityType.channel,
                    label: Text('کانال'),
                    icon: Icon(Icons.campaign_rounded),
                  ),
                ],
                selected: {type},
                onSelectionChanged: (value) =>
                    setLocalState(() => type = value.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () async {
                if (title.text.trim().isEmpty) return;
                await appState.createCommunity(
                  title: title.text.trim(),
                  description: description.text.trim(),
                  type: type,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('ساخت'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    description.dispose();
  }
}
