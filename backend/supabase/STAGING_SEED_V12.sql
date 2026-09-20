-- Patogh v12 staging seed for real multi-user closed beta.
-- Safe on staging only. It creates deterministic categories/events with zero
-- synthetic reservations so capacity is calculated from real tester bookings.

insert into public.categories(id,title,subtitle,icon_code_point,color_value,sort_order,is_active)
values
('intro','پاتوق آشنایی','آشنایی و گفت‌وگوی دوستانه',59375,4284190207,1,true),
('talk','پاتوق گفت‌وگو','گفت‌وگوی صمیمی و موضوعی',57535,4294212279,2,true),
('game','پاتوق بازی','تفریح و بازی گروهی',59944,4284386815,3,true),
('work','پاتوق کاری','شبکه‌سازی و ارتباط کاری',59641,4283149290,4,true),
('learn','پاتوق آموزشی','کارگاه و یادگیری گروهی',58378,4294941244,5,true),
('travel','پاتوق سفر','گشت شهری و سفر کوتاه',61341,4287528790,6,true),
('think','پاتوق فکری','فرهنگی، فکری و کتاب',60302,4294081209,7,true),
('sport','پاتوق ورزشی','ورزش و فعالیت گروهی',59985,4294941496,8,true),
('story','پاتوق قصه','تجربه و داستان‌گویی',61255,4284910847,9,true),
('empathy','پاتوق همدلی','گفت‌وگو و حمایت اجتماعی',59517,4294207094,10,true),
('volunteer','پاتوق داوطلبانه','کار خیر و فعالیت اجتماعی',61900,4294933894,11,true),
('companion','پاتوق همراهی','قرار سبک و دوستانه',60109,4286487807,12,true)
on conflict(id) do update set
 title=excluded.title, subtitle=excluded.subtitle, icon_code_point=excluded.icon_code_point,
 color_value=excluded.color_value, sort_order=excluded.sort_order, is_active=excluded.is_active;

insert into public.patogh_events(
 id,category_id,title,subtitle,date_label,time_label,area,exact_location_note,
 price,capacity,reserved_count,women_only,discounted,discount_percent,
 description,participants,tags,published,approval_status
)
values
('dinner-01','intro','قرار شام پاتوق','دورهمی ۶ نفره برای آشنایی و گفت‌وگو','دوشنبه، ۲۲ تیر','۱۹ تا ۲۱','مشهد','محل دقیق در روز برگزاری اعلام می‌شود.',300000,6,0,false,false,0,'دورهمی کوچک برای تست چندکاربره رزرو و چت.','{}',array['کافه','گفت‌وگو','آشنایی'],true,'approved'),
('breakfast-01','intro','قرار صبحانه پاتوق','شروع روز با یک جمع کوچک و دوستانه','جمعه، ۲۶ تیر','۱۰ تا ۱۲','مشهد','محدوده سجاد؛ آدرس نهایی پس از تکمیل گروه.',250000,6,0,false,true,10,'قرار صبحگاهی برای تست رزرو، ظرفیت و بازخورد.','{}',array['صبحانه','کافه','آشنایی'],true,'approved'),
('think-01','think','ژورنال‌تراپی و گفت‌وگو','پاتوق فکری با تمرین نوشتن','دوشنبه، ۲۲ تیر','۱۹ تا ۲۱','مشهد','محدوده احمدآباد؛ آدرس نهایی روز رویداد.',280000,8,0,false,false,0,'پاتوق فکری نمونه برای تست دسته‌بندی و Matching.','{}',array['کتاب','نوشتن','گفت‌وگو'],true,'approved'),
('women-talk-01','talk','پاتوق گفت‌وگوی بانوان','گفت‌وگوی صمیمی در جمع محدود','سه‌شنبه، ۲۳ تیر','۱۹ تا ۲۱','مشهد','محدوده هاشمیه؛ آدرس نهایی بعد از تأیید.',240000,6,0,true,true,15,'نمونه رویداد با شرط حضور برای تست Eligibility.','{}',array['بانوان','گفت‌وگو','همدلی'],true,'approved'),
('game-01','game','شب بازی پاتوق','بازی رومیزی، رقابت دوستانه و آشنایی','پنجشنبه، ۲۵ تیر','۱۸ تا ۲۱','مشهد','محدوده وکیل‌آباد؛ آدرس نهایی پس از رزرو.',220000,10,0,false,true,20,'رویداد نمونه برای تست گروه، چت و خاطره.','{}',array['بازی','سرگرمی','گروهی'],true,'approved'),
('kids-01','learn','کارگاه بازی و خلاقیت کودک','ویژه کودکان ۵ تا ۹ سال با ثبت‌نام والد','جمعه، ۲۶ تیر','۱۶ تا ۱۸','مشهد','خانه بازی کودک؛ تحویل و دریافت با تأیید سرپرست.',190000,16,0,false,true,10,'رویداد کودک نمونه برای تست رزرو وابسته/والد.','{}',array['کودک','خانواده','خلاقیت'],true,'approved'),
('work-01','work','شبکه‌سازی خلاق پاتوق','برای فریلنسرها و نیروهای خلاق','شنبه، ۲۷ تیر','۱۷ تا ۱۹','مشهد','محدوده ملک‌آباد.',180000,12,0,false,false,0,'شبکه‌سازی نمونه برای تست نقش‌ها و تعامل چندکاربره.','{}',array['کار','فریلنس','شبکه‌سازی'],true,'approved')
on conflict(id) do update set
 category_id=excluded.category_id,title=excluded.title,subtitle=excluded.subtitle,
 date_label=excluded.date_label,time_label=excluded.time_label,area=excluded.area,
 exact_location_note=excluded.exact_location_note,price=excluded.price,capacity=excluded.capacity,
 reserved_count=0,women_only=excluded.women_only,discounted=excluded.discounted,
 discount_percent=excluded.discount_percent,description=excluded.description,
 participants='{}',tags=excluded.tags,published=true,approval_status='approved';
