import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patogh/bootstrap.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/state/startup_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class StartupDiagnosticPage extends StatelessWidget {
  const StartupDiagnosticPage({super.key});

  @override
  Widget build(BuildContext context) {
    final failed = startupState.isFailed;
    final details = startupState.technicalDetails;

    return Scaffold(
      backgroundColor: PatoghTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: PatoghTheme.brandGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'پاتوق',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    failed ? 'مشکل در راه‌اندازی' : 'در حال آماده‌سازی...',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: failed ? PatoghTheme.orange : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (!failed)
                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  if (!failed) const SizedBox(height: 24),
                  _InfoCard(
                    title: 'الان چه اتفاقی افتاده؟',
                    child: Text(
                      startupState.stage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoCard(
                    title: 'وضعیت اتصال',
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(
                          label: 'حالت: ${AppConfig.mode.toUpperCase()}',
                          ok: AppConfig.mode == 'staging',
                        ),
                        _StatusChip(
                          label:
                              'سرور: ${AppConfig.useSupabase ? 'فعال' : 'غیرفعال'}',
                          ok: AppConfig.useSupabase,
                        ),
                        _StatusChip(
                          label:
                              'اعلان: ${AppConfig.useFirebase ? 'فعال' : 'غیرفعال'}',
                          ok: AppConfig.useFirebase,
                        ),
                      ],
                    ),
                  ),
                  if (failed) ...[
                    const SizedBox(height: 14),
                    _InfoCard(
                      title: startupState.errorTitle ?? 'خطا',
                      child: Text(
                        startupState.errorMessage ?? 'راه‌اندازی کامل نشد.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (startupState.canRetry)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            bootstrapPatogh();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            'دوباره تلاش کن',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    if (startupState.canRetry) const SizedBox(height: 10),
                    if (details != null && details.isNotEmpty)
                      ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: const Text(
                          'جزئیات فنی برای بررسی',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                        children: [
                          SelectableText(
                            details,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: details),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'جزئیات فنی کپی شد؛ همین متن را برای بررسی بفرست.',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('کپی جزئیات'),
                          ),
                        ],
                      ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'این صفحه عمداً به‌جای صفحه سفید نشان داده می‌شود تا اگر سرویس یا شبکه مشکل داشت، مرحله مشکل را ببینیم.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PatoghTheme.muted,
                      fontSize: 12,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PatoghTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30365F)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool ok;

  const _StatusChip({
    required this.label,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: ok
            ? PatoghTheme.green.withAlpha(22)
            : PatoghTheme.orange.withAlpha(22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ok
              ? PatoghTheme.green.withAlpha(90)
              : PatoghTheme.orange.withAlpha(90),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ok ? PatoghTheme.green : PatoghTheme.orange,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
