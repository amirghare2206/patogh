import 'package:flutter/material.dart';
import 'package:patogh/models/v10_models.dart';
import 'package:patogh/state/v10_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminPrivateEventPricingPage extends StatefulWidget {
  const AdminPrivateEventPricingPage({super.key});

  @override
  State<AdminPrivateEventPricingPage> createState() =>
      _AdminPrivateEventPricingPageState();
}

class _AdminPrivateEventPricingPageState
    extends State<AdminPrivateEventPricingPage> {
  late final TextEditingController baseFee;
  late final TextEditingController includedInvites;
  late final TextEditingController extraInviteFee;
  late final TextEditingController smsFee;
  late final TextEditingController boostFee;
  late final TextEditingController premiumTemplateFee;

  @override
  void initState() {
    super.initState();
    final pricing = v10State.privateEventPricing;
    baseFee = TextEditingController(text: '${pricing.basePublishFee}');
    includedInvites = TextEditingController(text: '${pricing.includedInvites}');
    extraInviteFee = TextEditingController(text: '${pricing.extraInviteFee}');
    smsFee = TextEditingController(text: '${pricing.smsUnitFee}');
    boostFee = TextEditingController(text: '${pricing.boostFee}');
    premiumTemplateFee = TextEditingController(
      text: '${pricing.premiumTemplateFee}',
    );
  }

  @override
  void dispose() {
    baseFee.dispose();
    includedInvites.dispose();
    extraInviteFee.dispose();
    smsFee.dispose();
    boostFee.dispose();
    premiumTemplateFee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعرفه دعوت‌نامه و انتشار'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ساخت پیش‌نویس مراسم رایگان است. صاحب مراسم هنگام انتشار دعوت‌نامه هزینه خدمات پاتوق را می‌پردازد. تبلیغ عمومی و Boost فقط با انتخاب صریح صاحب مراسم فعال می‌شود.',
              style: TextStyle(color: Color(0xFFCCCCCC), height: 1.7),
            ),
          ),
          const SizedBox(height: 16),
          _numberField(baseFee, 'هزینه پایه انتشار (تومان)'),
          _numberField(includedInvites, 'تعداد دعوت داخل مبلغ پایه'),
          _numberField(extraInviteFee, 'هزینه هر دعوت اضافه (تومان)'),
          _numberField(smsFee, 'هزینه هر پیامک (تومان)'),
          _numberField(boostFee, 'هزینه افزایش دیده‌شدن / Boost'),
          _numberField(premiumTemplateFee, 'قالب حرفه‌ای دعوت‌نامه'),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('ذخیره تعرفه‌ها'),
          ),
          const SizedBox(height: 20),
          const Text(
            'نمونه محاسبه',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: v10State,
            builder: (context, _) {
              final quote = v10State.quotePrivateEvent(
                inviteCount: 50,
                smsCount: 50,
                includeBoost: true,
              );
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'مراسم ۵۰ نفره + ۵۰ پیامک + Boost = ${quote.total} تومان',
                  style: const TextStyle(
                    color: PatoghTheme.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _save() async {
    final current = v10State.privateEventPricing;
    await v10State.updatePrivateEventPricing(
      PrivateEventPricingConfig(
        basePublishFee: int.tryParse(baseFee.text) ?? current.basePublishFee,
        includedInvites:
            int.tryParse(includedInvites.text) ?? current.includedInvites,
        extraInviteFee:
            int.tryParse(extraInviteFee.text) ?? current.extraInviteFee,
        smsUnitFee: int.tryParse(smsFee.text) ?? current.smsUnitFee,
        boostFee: int.tryParse(boostFee.text) ?? current.boostFee,
        premiumTemplateFee:
            int.tryParse(premiumTemplateFee.text) ?? current.premiumTemplateFee,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعرفه‌ها در Demo ذخیره شد.')));
  }
}
