import 'package:flutter/material.dart';
import 'package:patogh/models/v11_models.dart';
import 'package:patogh/pages/golrizon_page.dart';
import 'package:patogh/state/v11_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class MemorialCenterPage extends StatelessWidget {
  const MemorialCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مموریال و یادبود')),
      body: const MemorialCenterEmbedded(),
    );
  }
}

class MemorialCenterEmbedded extends StatelessWidget {
  const MemorialCenterEmbedded({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: v11State,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مموریال',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'صفحه یادبود، دفتر خاطرات، سالگرد، مراسم و گل‌ریزون به نام فرد درگذشته',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _createMemorial(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ایجاد'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'برای صفحه رسمی یادبود، رابطه ایجادکننده با فرد درگذشته و تأیید خانواده/ادمین در Production بررسی می‌شود تا جلوی سوءاستفاده گرفته شود.',
                style: TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...v11State.memorials.map((item) => _memorialCard(context, item)),
          ],
        );
      },
    );
  }
}

Widget _memorialCard(BuildContext context, MemorialProfile item) {
  final messages = v11State.memorialMessages
      .where((message) => message.memorialId == item.id)
      .toList();
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF202020), Color(0xFF121212)],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFF2D2D2D)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF2C2C2C),
              child: Icon(
                Icons.local_florist_rounded,
                color: PatoghTheme.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.personName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    item.lifeLabel,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Chip(label: Text(item.visibility.label)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          item.relationLabel,
          style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          item.anniversaryLabel,
          style: const TextStyle(color: PatoghTheme.orange, fontSize: 11),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('${item.memoryCount} خاطره'),
            const SizedBox(width: 12),
            Text('${item.condolenceCount} پیام'),
            const Spacer(),
            Text(
              item.status == MemorialStatus.verified
                  ? 'تأیید شده ✓'
                  : 'در انتظار بررسی',
              style: TextStyle(
                color: item.status == MemorialStatus.verified
                    ? const Color(0xFF7BE0A8)
                    : const Color(0xFFFFC36B),
                fontSize: 10,
              ),
            ),
          ],
        ),
        if (messages.isNotEmpty) ...[
          const Divider(height: 24),
          Text(
            messages.first.text,
            style: const TextStyle(color: Color(0xFFCCCCCC), height: 1.6),
          ),
          const SizedBox(height: 5),
          Text(
            messages.first.authorLabel,
            style: const TextStyle(color: Color(0xFF777777), fontSize: 9),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _addMessage(context, item.id),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('دفتر یادبود'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const GolrizonPage())),
              icon: const Icon(Icons.volunteer_activism_rounded),
              label: const Text('گل‌ریزون به یاد او'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.event_rounded),
              label: const Text('مراسم سالگرد'),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _createMemorial(BuildContext context) async {
  final name = TextEditingController();
  final life = TextEditingController();
  final relation = TextEditingController();
  final anniversary = TextEditingController(text: 'یادآوری سالانه');
  var visibility = MemorialVisibility.familyOnly;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: const Text('ایجاد مموریال'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'نام فرد'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: life,
                    decoration: const InputDecoration(
                      labelText: 'سال تولد/درگذشت یا توضیح کوتاه',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: relation,
                    decoration: const InputDecoration(
                      labelText: 'نسبت شما با فرد',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: anniversary,
                    decoration: const InputDecoration(
                      labelText: 'یادآوری سالگرد',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<MemorialVisibility>(
                    initialValue: visibility,
                    decoration: const InputDecoration(labelText: 'سطح دسترسی'),
                    items: MemorialVisibility.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() => visibility = value);
                      }
                    },
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
                  if (name.text.trim().isEmpty ||
                      relation.text.trim().isEmpty) {
                    return;
                  }
                  await v11State.createMemorial(
                    personName: name.text.trim(),
                    lifeLabel: life.text.trim(),
                    relationLabel: relation.text.trim(),
                    anniversaryLabel: anniversary.text.trim(),
                    visibility: visibility,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('ارسال برای بررسی'),
              ),
            ],
          );
        },
      );
    },
  );

  name.dispose();
  life.dispose();
  relation.dispose();
  anniversary.dispose();
}

Future<void> _addMessage(BuildContext context, String memorialId) async {
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('پیام یا خاطره یادبود'),
      content: TextField(
        controller: controller,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'خاطره، متن یا پیام یادبود...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () async {
            await v11State.addMemorialMessage(
              memorialId: memorialId,
              authorLabel: 'کاربر پاتوق',
              text: controller.text,
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: const Text('ثبت'),
        ),
      ],
    ),
  );
  controller.dispose();
}
