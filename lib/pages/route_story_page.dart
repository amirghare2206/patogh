import 'package:flutter/material.dart';
import 'package:patogh/models/engagement_models.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/state/engagement_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class RouteStoryPage extends StatefulWidget {
  const RouteStoryPage({super.key});

  @override
  State<RouteStoryPage> createState() => _RouteStoryPageState();
}

class _RouteStoryPageState extends State<RouteStoryPage> {
  String? selectedRouteId;

  @override
  Widget build(BuildContext context) {
    final selected = engagementState.routes.firstWhere(
      (route) =>
          route.id == (selectedRouteId ?? engagementState.routes.first.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('مسیر پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: engagementState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'در نسخه واقعی، کاربر خودش «شروع مسیر» را فعال می‌کند. موقعیت فقط در طول Session برای پیشنهاد داستان‌های نزدیک استفاده می‌شود و امکان دانلود آفلاین روایت‌ها پیش‌بینی شده است.',
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 11,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: selected.id,
                decoration: const InputDecoration(labelText: 'مسیر نمونه'),
                items: engagementState.routes
                    .map(
                      (route) => DropdownMenuItem(
                        value: route.id,
                        child: Text('${route.origin} ← ${route.destination}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedRouteId = value),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${selected.origin} ← ${selected.destination}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selected.corridor.join(' • '),
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: engagementState.routeSessionActive
                          ? engagementState.endRoute
                          : () => engagementState.startRoute(selected.id),
                      icon: Icon(
                        engagementState.routeSessionActive
                            ? Icons.stop_circle_outlined
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        engagementState.routeSessionActive
                            ? 'پایان مسیر'
                            : 'شروع مسیر پاتوق',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'داستان‌ها و فرصت‌های مسیر',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...selected.stories.map((story) => _storyCard(context, story)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _submitStory(context),
                icon: const Icon(Icons.mic_rounded),
                label: const Text('روایت محلی پیشنهاد بده'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _storyCard(BuildContext context, PlaceStory story) {
    final listened = engagementState.listenedStoryIds.contains(story.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Chip(label: Text(story.type.label)),
              const SizedBox(width: 6),
              if (story.verified)
                const Icon(
                  Icons.verified_rounded,
                  color: PatoghTheme.orange,
                  size: 18,
                ),
              const Spacer(),
              Text(
                story.durationLabel,
                style: const TextStyle(color: Color(0xFF999999), fontSize: 10),
              ),
            ],
          ),
          Text(
            story.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Text(
            story.placeLabel,
            style: const TextStyle(color: PatoghTheme.orange, fontSize: 11),
          ),
          const SizedBox(height: 7),
          Text(
            story.summary,
            style: const TextStyle(
              color: Color(0xFFBBBBBB),
              height: 1.6,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await engagementState.listenToStory(story);
              if (!context.mounted) return;
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        story.storyText,
                        style: const TextStyle(height: 1.8),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'راوی/منبع: ${story.authorLabel}',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: Icon(
              listened ? Icons.check_circle_rounded : Icons.headphones_rounded,
            ),
            label: Text(listened ? 'شنیده شد' : 'شنیدن / خواندن روایت'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitStory(BuildContext context) async {
    final title = TextEditingController();
    final place = TextEditingController(text: appState.selectedCity);
    final body = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('پیشنهاد روایت محلی'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: place,
                decoration: const InputDecoration(labelText: 'مکان'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'عنوان روایت'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: body,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'متن یا خلاصه روایت',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isEmpty || body.text.trim().isEmpty) return;
              await engagementState.submitLocalStory(
                author: appState.profile?.name ?? 'کاربر پاتوق',
                placeLabel: place.text.trim(),
                title: title.text.trim(),
                text: body.text.trim(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ارسال برای بررسی'),
          ),
        ],
      ),
    );
    title.dispose();
    place.dispose();
    body.dispose();
  }
}
