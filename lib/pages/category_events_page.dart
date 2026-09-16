import 'package:flutter/material.dart';
import 'package:patogh/data/mock_data.dart';
import 'package:patogh/models/patogh_category.dart';
import 'package:patogh/pages/event_detail_page.dart';
import 'package:patogh/widgets/event_card.dart';

class CategoryEventsPage extends StatelessWidget {
  final PatoghCategory category;

  const CategoryEventsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryEvents = eventsForCategory(category.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: categoryEvents.isEmpty
              ? const Center(child: Text('فعلاً پاتوقی در این دسته ثبت نشده.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                  itemCount: categoryEvents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final event = categoryEvents[index];
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
      ),
    );
  }
}
