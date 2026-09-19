import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class MyCirclePage extends StatelessWidget {
  const MyCirclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حلقه من'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'دوستان و اعضای خانواده را اضافه کن. اگر خودشان اجازه بدهند، وقتی در یک رویداد شرکت کردی پاتوق می‌تواند به‌جای تو خبرشان کند.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              const SizedBox(height: 16),
              ...appState.circleMembers.map(
                (member) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                    child: SwitchListTile(
                      value: member.notifyOnEventJoin,
                      onChanged: member.accepted
                          ? (_) => appState.toggleCircleNotification(member.id)
                          : null,
                      secondary: CircleAvatar(
                        backgroundColor: const Color(0xFF2A2A2A),
                        child: Text(member.name.characters.first),
                      ),
                      title: Text(
                        member.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        member.accepted
                            ? '${member.relation} • ارتباط تأییدشده'
                            : '${member.relation} • منتظر تأیید',
                        style: TextStyle(
                          color: member.accepted
                              ? PatoghTheme.green
                              : const Color(0xFFFFC36B),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _invite(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('دعوت دوست یا عضو خانواده'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _invite(BuildContext context) async {
    final name = TextEditingController();
    final relation = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('دعوت به حلقه من'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'نام / شماره کاربر'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: relation,
              decoration: const InputDecoration(
                labelText: 'نسبت؛ دوست، همسر، خواهر...',
              ),
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
              if (name.text.trim().isEmpty) return;
              await appState.addCircleMember(
                name.text.trim(),
                relation.text.trim(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ارسال دعوت'),
          ),
        ],
      ),
    );
    name.dispose();
    relation.dispose();
  }
}
