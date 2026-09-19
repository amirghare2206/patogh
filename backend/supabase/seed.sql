insert into public.patogh_events (
  id, category_id, title, subtitle, date_label, time_label,
  area, exact_location_note, price, capacity, reserved_count,
  women_only, discounted, discount_percent, description,
  participants, tags, published
)
values
(
  'dinner-01', 'intro', 'قرار شام پاتوق',
  'دورهمی ۶ نفره برای آشنایی و گفت‌وگو',
  'دوشنبه، ۲۲ تیر', '۱۹ تا ۲۱', 'مشهد',
  'محل دقیق در روز برگزاری اعلام می‌شود.',
  300000, 6, 6, false, false, 0,
  'یک دورهمی کوچک و واقعی برای آشنایی با آدم‌های تازه.',
  array['مریم','علی','ندا','رضا'],
  array['کافه','گفت‌وگو','آشنایی'],
  true
),
(
  'breakfast-01', 'intro', 'قرار صبحانه پاتوق',
  'شروع روز با یک جمع کوچک و دوستانه',
  'جمعه، ۲۶ تیر', '۱۰ تا ۱۲', 'مشهد',
  'محدوده سجاد؛ آدرس نهایی پس از تکمیل گروه.',
  250000, 6, 4, false, true, 10,
  'یک قرار سبک صبحگاهی برای آشنایی با آدم‌های جدید.',
  array['سارا','امیر','آتنا'],
  array['صبحانه','کافه','آشنایی'],
  true
)
on conflict (id) do nothing;
