import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  late bool showAge;
  late bool allowChat;

  @override
  void initState() {
    super.initState();
    showAge = appState.profile?.showAge ?? true;
    allowChat = appState.profile?.allowChat ?? true;
  }

  Future<void> _save() async {
    final profile = appState.profile;
    if (profile == null) return;
    await appState.saveProfile(
      profile.copyWith(showAge: showAge, allowChat: allowChat),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حریم خصوصی'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          SwitchListTile(
            value: showAge,
            onChanged: (v) async {
              setState(() => showAge = v);
              await _save();
            },
            title: const Text('نمایش سن'),
          ),
          SwitchListTile(
            value: allowChat,
            onChanged: (v) async {
              setState(() => allowChat = v);
              await _save();
            },
            title: const Text('اجازه چت پس از پاتوق'),
          ),
        ],
      ),
    );
  }
}
