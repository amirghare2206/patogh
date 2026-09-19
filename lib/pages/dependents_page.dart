import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class DependentsPage extends StatelessWidget {
  const DependentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فرزندان و افراد تحت سرپرستی'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'برای رویدادهای کودک و خانوادگی، والد یا سرپرست صاحب حساب است و شرکت‌کننده می‌تواند فرزند او باشد.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              const SizedBox(height: 14),
              ...appState.dependents.map(
                (child) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2A2A2A),
                        child: Icon(
                          Icons.child_care_rounded,
                          color: PatoghTheme.orange,
                        ),
                      ),
                      title: Text(
                        child.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('${child.age} سال • ${child.relation}'),
                      trailing: const Icon(
                        Icons.verified_user_outlined,
                        color: PatoghTheme.green,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('افزودن فرزند / فرد تحت سرپرستی'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'اطلاعات کودک پروفایل عمومی مستقل ندارد. برای رویدادهای بدون حضور والد، تحویل کودک فقط به سرپرست یا افراد مجاز ثبت‌شده انجام می‌شود و نسخه Production می‌تواند QR یا کد یک‌بارمصرف تحویل داشته باشد.',
                  style: TextStyle(
                    color: Color(0xFFB8B8B8),
                    fontSize: 11,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final name = TextEditingController();
    final age = TextEditingController();
    final relation = TextEditingController(text: 'فرزند');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('افزودن فرد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'نام'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سن'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: relation,
              decoration: const InputDecoration(labelText: 'نسبت'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              final parsedAge = int.tryParse(age.text.trim());
              if (name.text.trim().isEmpty || parsedAge == null) return;
              await appState.addDependent(
                name.text.trim(),
                parsedAge,
                relation.text.trim().isEmpty ? 'فرزند' : relation.text.trim(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );

    name.dispose();
    age.dispose();
    relation.dispose();
  }
}
