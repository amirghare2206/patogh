import 'package:flutter/material.dart';
import 'package:patogh/models/place.dart';

const List<Place> allPlaces = [
  Place(
    title: 'بوستان کوهسنگی',
    category: 'گردشگری',
    area: 'کوهسنگی',
    rating: '۴.۸',
    distance: '۳.۱ کیلومتر',
    description: 'یکی از شناخته‌شده‌ترین فضاهای گردشگری مشهد با فضای سبز، مسیر پیاده‌روی و چشم‌انداز شهری.',
    icon: Icons.landscape_rounded,
    background: Color(0xFFE5F2EE),
    foreground: Color(0xFF276A5B),
  ),
  Place(
    title: 'پارک ملت',
    category: 'تفریح',
    area: 'وکیل‌آباد',
    rating: '۴.۷',
    distance: '۲.۴ کیلومتر',
    description: 'فضای سبز بزرگ شهری با امکانات تفریحی، ورزشی و شهربازی.',
    icon: Icons.park_rounded,
    background: Color(0xFFECEAF8),
    foreground: Color(0xFF57508A),
  ),
  Place(
    title: 'طرقبه',
    category: 'گردشگری',
    area: 'طرقبه',
    rating: '۴.۹',
    distance: '۱۸ کیلومتر',
    description:
        'منطقه‌ای گردشگری و خوش‌آب‌وهوا با طبیعت، رستوران‌ها و مسیرهای تفریحی.',
    icon: Icons.forest_rounded,
    background: Color(0xFFF5EEE3),
    foreground: Color(0xFF855E3E),
  ),
  Place(
    title: 'باغ ملی',
    category: 'فرهنگی',
    area: 'مرکز شهر',
    rating: '۴.۴',
    distance: '۱.۲ کیلومتر',
    description:
        'فضایی آرام و تاریخی در مرکز شهر، مناسب برای قدم‌زدن و استراحت.',
    icon: Icons.account_balance_rounded,
    background: Color(0xFFE7EFF8),
    foreground: Color(0xFF3F6283),
  ),
  Place(
    title: 'بوستان وکیل‌آباد',
    category: 'طبیعت',
    area: 'وکیل‌آباد',
    rating: '۴.۶',
    distance: '۹ کیلومتر',
    description:
        'بوستانی قدیمی و سرسبز با فضای مناسب برای گردش خانوادگی و طبیعت‌گردی.',
    icon: Icons.nature_people_rounded,
    background: Color(0xFFEAF3E4),
    foreground: Color(0xFF50734A),
  ),
];
