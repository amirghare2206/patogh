import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';
import 'package:patogh/widgets/profile_avatar_picker.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  late Future<List<Map<String, dynamic>>> _peopleFuture;
  Timer? _refreshDebounce;
  bool _refreshQueued = false;

  @override
  void initState() {
    super.initState();
    _peopleFuture = _loadPeople();
    appState.addListener(_onSharedStateChanged);
  }

  void _onSharedStateChanged() {
    if (!mounted || !AppConfig.useSupabase) return;
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 800), () {
      if (!mounted || _refreshQueued) return;
      _refreshQueued = true;
      setState(() => _peopleFuture = _loadPeople());
      // Release the guard on the next event-loop turn; the future itself is
      // owned by FutureBuilder and does not mutate AppState.
      scheduleMicrotask(() => _refreshQueued = false);
    });
  }

  @override
  void dispose() {
    appState.removeListener(_onSharedStateChanged);
    _refreshDebounce?.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadPeople() {
    if (!AppConfig.useSupabase) return Future.value(const []);
    return PlatformServices.fetchSuggestedProfilesV14();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('هم‌پاتوقی‌های پیشنهادی'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'تلاش دوباره',
            onPressed: () => setState(() => _peopleFuture = _loadPeople()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _peopleFuture,
        builder: (context, snapshot) {
          if (!AppConfig.useSupabase) {
            return const _MatchingEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'پیشنهاد واقعی در حالت آفلاین در دسترس نیست',
              message: 'برای دیدن هم‌پاتوقی‌های واقعی، نسخه Staging باید به سرور وصل باشد.',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MatchingEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'دریافت پیشنهادها انجام نشد',
              message:
                  'اتصال و نصب Migration پیشنهاد هم‌پاتوقی را بررسی کن.\n${snapshot.error}',
              onRetry: () => setState(() => _peopleFuture = _loadPeople()),
            );
          }
          final people = snapshot.data ?? const <Map<String, dynamic>>[];
          if (people.isEmpty) {
            return const _MatchingEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'هنوز هم‌پاتوقی پیشنهادی پیدا نشد',
              message: 'وقتی کاربران دیگر ثبت‌نام کنند و علایقشان را کامل کنند، پیشنهادها اینجا نمایش داده می‌شوند.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: people.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final person = people[index];
              final name =
                  (person['name'] as String?)?.trim().isNotEmpty == true
                  ? (person['name'] as String).trim()
                  : 'کاربر پاتوق';
              final city = (person['city'] as String?) ?? '';
              final interests = List<String>.from(
                (person['shared_interests'] as List?) ?? const [],
              );
              final tags = List<String>.from(
                (person['shared_tags'] as List?) ?? const [],
              );
              final personality = (person['personality_type'] as String?) ?? '';
              final leisure = (person['leisure_style'] as String?) ?? '';
              final showAge = (person['show_age'] as bool?) ?? false;
              final age = person['age'];
              final shared = <String>{...interests, ...tags}.toList();
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: PatoghTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF343958)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileAvatarImage(
                      avatarUrl: person['avatar_url'] as String?,
                      radius: 27,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (city.isNotEmpty) city,
                              if (showAge && age is num) '${age.toInt()} سال',
                            ].join(' • '),
                            style: const TextStyle(
                              color: PatoghTheme.muted,
                              fontSize: 11,
                            ),
                          ),
                          if (personality.isNotEmpty || leisure.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              [
                                personality,
                                leisure,
                              ].where((v) => v.isNotEmpty).join(' • '),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            shared.isEmpty
                                ? 'هنوز علاقه مشترکی ثبت نشده.'
                                : 'علایق مشترک: ${shared.join('، ')}',
                            style: const TextStyle(
                              color: PatoghTheme.teal,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'پیشنهاد بر اساس داده‌های پروفایل؛ بدون امتیاز یا تشخیص روان‌شناختی ساختگی.',
                            style: TextStyle(
                              color: PatoghTheme.muted,
                              fontSize: 9,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MatchingEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  const _MatchingEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: PatoghTheme.teal),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PatoghTheme.muted,
              height: 1.7,
              fontSize: 12,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش دوباره'),
            ),
          ],
        ],
      ),
    ),
  );
}
