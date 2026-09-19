import 'package:flutter/material.dart';
import 'package:patogh/models/v11_models.dart';
import 'package:patogh/state/v11_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class TimeEngineAdminPage extends StatelessWidget {
  const TimeEngineAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: v11State,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'مدیریت زمان و مناسبت',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'کنترل منابع تقویم، مناسبت‌های پویا، فرصت‌های تولید رویداد و مموریال‌های نیازمند بررسی.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.6),
              ),
              const SizedBox(height: 18),
              _metric(
                'منابع فعال',
                '${v11State.enabledLayers.length}',
                Icons.sync_rounded,
              ),
              _metric(
                'فرصت تولید رویداد',
                '${v11State.opportunities.length}',
                Icons.auto_awesome_rounded,
              ),
              _metric(
                'مموریال در انتظار بررسی',
                '${v11State.memorials.where((item) => item.status == MemorialStatus.pending).length}',
                Icons.fact_check_rounded,
              ),
              const SizedBox(height: 18),
              const Text(
                'مموریال‌های نیازمند بررسی',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...v11State.memorials
                  .where((item) => item.status == MemorialStatus.pending)
                  .map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181818),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_florist_rounded,
                            color: PatoghTheme.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.personName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          FilledButton(
                            onPressed: () => v11State.approveMemorial(item.id),
                            child: const Text('تأیید'),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 18),
              const Text(
                'منابع نمونه',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...v11State.occasions.map(
                (item) => ListTile(
                  leading: const Icon(
                    Icons.source_rounded,
                    color: PatoghTheme.orange,
                  ),
                  title: Text(item.sourceLabel),
                  subtitle: Text(
                    '${item.title} • ${item.sourceVersion} • ${item.certaintyLabel}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: PatoghTheme.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
