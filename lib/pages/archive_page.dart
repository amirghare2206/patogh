import 'package:flutter/material.dart';
import 'package:patogh/data/mock_data.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/widgets/event_banner.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  int tab = 0;
  final labels = const [
    'شرکت کرده‌ام',
    'برگزار کرده‌ام',
    'لغوشده',
    'علاقه‌مندی‌ها',
  ];

  @override
  Widget build(BuildContext context) {
    final list = tab == 3
        ? events.where((e) => appState.favoriteIds.contains(e.id)).toList()
        : events.take(tab == 2 ? 1 : 2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('آرشیو پاتوق‌ها'),
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
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: labels.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ChoiceChip(
                    label: Text(labels[index]),
                    selected: tab == index,
                    onSelected: (_) => setState(() => tab = index),
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('موردی وجود ندارد.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(18),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 22),
                        itemBuilder: (context, index) => EventBanner(
                          event: list[index],
                          compact: true,
                          onTap: () {},
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
