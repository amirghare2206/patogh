import 'package:flutter/material.dart';
import 'package:patogh/pages/auth/profile_setup_page.dart';
import 'package:patogh/state/app_state.dart';

class OtpPage extends StatefulWidget {
  final String phone;

  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final codeController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأیید شماره'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'کد ارسال‌شده به ${widget.phone}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: '1234'),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);
                          try {
                            await appState.verifyDemoOtp(
                              widget.phone,
                              codeController.text.trim(),
                            );

                            if (!context.mounted) return;

                            if (appState.profile == null) {
                              await Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const ProfileSetupPage(),
                                ),
                              );
                            } else {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            if (mounted) setState(() => loading = false);
                          }
                        },
                  child: Text(loading ? 'در حال بررسی...' : 'ورود'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
