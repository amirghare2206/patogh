import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminBannerCampaignPage extends StatelessWidget {
  const AdminBannerCampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بنرها و کمپین‌ها'),
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
                'بنرها می‌توانند در صفحه اصلی، دسته‌بندی، جزئیات رویداد، تایم‌لاین، استوری، گروه، پروفایل، پرداخت و پنل‌های تخصصی نمایش داده شوند.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _addBanner(context),
                      icon: const Icon(Icons.view_carousel_rounded),
                      label: const Text('بنر جدید'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addCampaign(context),
                      icon: const Icon(Icons.discount_rounded),
                      label: const Text('کد تخفیف'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'بنرهای فعال',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              const SizedBox(height: 8),
              ...appState.banners.map(
                (banner) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF392414), Color(0xFF181818)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (banner.imageAsset != null ||
                          banner.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: banner.imageAsset != null
                                ? Image.asset(
                                    banner.imageAsset!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    banner.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const ColoredBox(
                                      color: PatoghTheme.surface2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              banner.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (banner.sponsored)
                            const Text(
                              'اسپانسرشده',
                              style: TextStyle(
                                color: PatoghTheme.orange,
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        banner.subtitle,
                        style: const TextStyle(color: Color(0xFFCCCCCC)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'جایگاه: ${banner.placement} • مخاطب: ${banner.audience}',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'کدهای فعال',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              const SizedBox(height: 8),
              ...appState.discountCampaigns.map(
                (campaign) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${campaign.audience} • ${campaign.code}',
                              style: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${campaign.percent}٪',
                        style: const TextStyle(
                          color: PatoghTheme.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addBanner(BuildContext context) async {
    final title = TextEditingController();
    final subtitle = TextEditingController();
    final audience = TextEditingController(text: 'همه کاربران');
    final imageUrl = TextEditingController();
    var placement = 'home';
    var sponsored = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('بنر جدید'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'عنوان'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subtitle,
                  decoration: const InputDecoration(labelText: 'توضیح'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: audience,
                  decoration: const InputDecoration(labelText: 'مخاطب'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'لینک تصویر بنر (اختیاری)',
                    hintText: 'https://.../banner.jpg',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: placement,
                  items:
                      const [
                            'home',
                            'category',
                            'event_detail',
                            'timeline',
                            'stories',
                            'communities',
                            'profile',
                            'checkout',
                            'venue_panel',
                            'organizer_panel',
                            'enterprise_panel',
                          ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) setLocalState(() => placement = value);
                  },
                  decoration: const InputDecoration(labelText: 'جایگاه نمایش'),
                ),
                SwitchListTile(
                  value: sponsored,
                  onChanged: (value) => setLocalState(() => sponsored = value),
                  title: const Text('تبلیغ / اسپانسرشده'),
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
                if (title.text.trim().isEmpty) return;
                await appState.addBanner(
                  title: title.text.trim(),
                  subtitle: subtitle.text.trim(),
                  placement: placement,
                  audience: audience.text.trim(),
                  sponsored: sponsored,
                  imageUrl: imageUrl.text.trim(),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('انتشار'),
            ),
          ],
        ),
      ),
    );

    title.dispose();
    subtitle.dispose();
    audience.dispose();
    imageUrl.dispose();
  }

  Future<void> _addCampaign(BuildContext context) async {
    final title = TextEditingController();
    final code = TextEditingController();
    final audience = TextEditingController(text: 'همه کاربران');
    final percent = TextEditingController(text: '10');
    final maxDiscount = TextEditingController(text: '100000');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('کد تخفیف جدید'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'عنوان جشنواره'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: code,
                decoration: const InputDecoration(labelText: 'کد'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: audience,
                decoration: const InputDecoration(labelText: 'مخاطب'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: percent,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'درصد تخفیف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: maxDiscount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سقف تخفیف'),
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
              final p = int.tryParse(percent.text.trim());
              final m = int.tryParse(maxDiscount.text.trim());
              if (title.text.trim().isEmpty ||
                  code.text.trim().isEmpty ||
                  p == null ||
                  m == null) {
                return;
              }
              await appState.addDiscountCampaign(
                title: title.text.trim(),
                code: code.text.trim(),
                audience: audience.text.trim(),
                percent: p,
                maxDiscount: m,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ساخت'),
          ),
        ],
      ),
    );

    title.dispose();
    code.dispose();
    audience.dispose();
    percent.dispose();
    maxDiscount.dispose();
  }
}
