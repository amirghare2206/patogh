import 'package:flutter/material.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/pages/legal_page.dart';
import 'package:patogh/services/platform_services.dart';
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
        title: const Text('حریم خصوصی و حساب'),
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
          const Divider(height: 32),
          _legalTile(context, 'سیاست حریم خصوصی', LegalPage.privacy),
          _legalTile(context, 'شرایط استفاده', LegalPage.terms),
          _legalTile(context, 'قواعد جامعه پاتوق', LegalPage.community),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _deleteAccount,
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('حذف حساب و داده‌های من'),
          ),
        ],
      ),
    );
  }

  Widget _legalTile(BuildContext context, String title, String body) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LegalPage(title: title, body: body),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف حساب؟'),
        content: const Text(
          'این کار غیرقابل بازگشت است و حساب کاربری و داده‌های وابسته را حذف می‌کند.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف حساب'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      if (AppConfig.useSupabase) await PlatformServices.deleteMyAccountV12();
      await appState.logout();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('حذف حساب ناموفق بود: $e')));
      }
    }
  }
}
