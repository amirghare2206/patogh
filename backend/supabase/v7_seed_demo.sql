-- Optional demo content for Patogh v7

insert into public.campaigns (
  id, title, campaign_type, audience_rules, active
)
values
  ('00000000-0000-0000-0000-000000000701', 'اولین پاتوق', 'discount', '{"new_user":true}'::jsonb, true),
  ('00000000-0000-0000-0000-000000000702', 'دوستات رو بیار', 'discount', '{"group_min":4}'::jsonb, true)
on conflict (id) do nothing;

insert into public.discount_codes (
  campaign_id, code, discount_type, value, max_discount, active
)
values
  ('00000000-0000-0000-0000-000000000701', 'FIRST20', 'percent', 20, 150000, true),
  ('00000000-0000-0000-0000-000000000702', 'GROUP15', 'percent', 15, 400000, true)
on conflict (code) do nothing;

insert into public.banners (
  id, title, subtitle, action_label, action_type, action_target, sponsored, audience_rules, priority, active
)
values
  ('00000000-0000-0000-0000-000000000711', 'جشنواره اولین پاتوق', '۲۰٪ تخفیف برای اولین تجربه', 'مشاهده جشنواره', 'campaign', '00000000-0000-0000-0000-000000000701', false, '{"new_user":true}'::jsonb, 10, true),
  ('00000000-0000-0000-0000-000000000712', 'تجربه‌ات را ثبت کن', 'بازخورد واقعی به افزایش کیفیت پاتوق کمک می‌کند', 'ثبت تجربه', 'page', '/feedback', false, '{}'::jsonb, 5, true)
on conflict (id) do nothing;

insert into public.banner_placements (banner_id, placement)
values
  ('00000000-0000-0000-0000-000000000711','home'),
  ('00000000-0000-0000-0000-000000000711','checkout'),
  ('00000000-0000-0000-0000-000000000712','timeline')
on conflict do nothing;
