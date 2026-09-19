import 'package:flutter/material.dart';
import 'package:patogh/data/mock_data.dart';
import 'package:patogh/pages/event_detail_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/widgets/event_card.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  int selected = 0;

  final labels = const [
    'شرکت کرده‌ام',
    'برگزار کرده‌ام',
    'لغوشده',
    'علاقه‌مندی‌ها',
  ];

  @override
  Widget build(BuildContext context) {
    final list = switch (selected) {
      0 =>
        events
            .where((event) => appState.reservedIds.contains(event.id))
            .toList(),
      1 => events.take(1).toList(),
      2 => events.skip(1).take(1).toList(),
      _ =>
        events
            .where((event) => appState.favoriteIds.contains(event.id))
            .toList(),
    };

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
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      label: Text(labels[index]),
                      selected: selected == index,
                      onSelected: (_) {
                        setState(() => selected = index);
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Text(
                          'هنوز موردی در این بخش وجود ندارد.',
                          style: TextStyle(color: Color(0xFFAAAAAA)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(18),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 22),
                        itemBuilder: (context, index) {
                          final event = list[index];
                          return EventCard(
                            event: event,
                            compact: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EventDetailPage(event: event),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
