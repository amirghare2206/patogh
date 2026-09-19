import 'package:flutter/material.dart';

class AdminModerationPage extends StatelessWidget {
  const AdminModerationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final reports = const [
      ('گزارش رفتار نامناسب', 'کاربر ۱۲۸', 'باز'),
      ('گزارش محتوای نامرتبط', 'کانال سفر', 'در حال بررسی'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('گزارش تخلف و نظارت'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: reports
            .map(
              (r) => Card(
                child: ListTile(
                  leading: const Icon(Icons.report_problem_rounded),
                  title: Text(r.$1),
                  subtitle: Text(r.$2),
                  trailing: Text(r.$3),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
