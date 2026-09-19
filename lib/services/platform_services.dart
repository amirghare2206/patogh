import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:patogh/config/app_config.dart';
import 'package:patogh/models/chat_message.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/models/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentStartResult {
  final String? url;
  final String? reference;
  final bool demo;

  const PaymentStartResult({this.url, this.reference, this.demo = false});
}

class PlatformServices {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (AppConfig.useSupabase) {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
    }

    if (AppConfig.useFirebase) {
      await Firebase.initializeApp(options: AppConfig.firebaseOptions);
    }

    _initialized = true;
  }

  static SupabaseClient? get _supabase =>
      AppConfig.useSupabase ? Supabase.instance.client : null;

  static String? get currentUserId => _supabase?.auth.currentUser?.id;

  static bool get hasRemoteSession => currentUserId != null;

  static String normalizeIranPhone(String input) {
    final phone = input.replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('+98')) return phone;
    if (phone.startsWith('0098')) return '+${phone.substring(2)}';
    if (phone.startsWith('09')) return '+98${phone.substring(1)}';
    return phone;
  }

  static Future<void> requestOtp(String phone) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.auth.signInWithOtp(phone: normalizeIranPhone(phone));
  }

  static Future<void> verifyOtp(String phone, String code) async {
    if (!AppConfig.useSupabase) {
      if (code != '1234') {
        throw Exception('کد آزمایشی صحیح 1234 است.');
      }
      return;
    }

    await _supabase!.auth.verifyOTP(
      phone: normalizeIranPhone(phone),
      token: code,
      type: OtpType.sms,
    );
  }

  static Future<void> signOut() async {
    if (AppConfig.useSupabase) {
      await _supabase!.auth.signOut();
    }
  }

  static Future<UserProfile?> loadProfile() async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return null;

    final row = await _supabase!
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return null;

    return UserProfile(
      name: (row['name'] as String?) ?? 'کاربر پاتوق',
      age: (row['age'] as num?)?.toInt() ?? 25,
      city: (row['city'] as String?) ?? 'مشهد',
      interests: List<String>.from(
        (row['interests'] as List?) ?? const <String>[],
      ),
      showAge: (row['show_age'] as bool?) ?? true,
      allowChat: (row['allow_chat'] as bool?) ?? true,
      role: UserRoleX.fromKey(row['role'] as String?),
    );
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;

    await _supabase!.from('profiles').upsert({
      'id': userId,
      'phone': _supabase!.auth.currentUser?.phone,
      'name': profile.name,
      'age': profile.age,
      'city': profile.city,
      'interests': profile.interests,
      'show_age': profile.showAge,
      'allow_chat': profile.allowChat,
      'role': profile.role.key,
    });
  }

  static Future<List<PatoghEvent>> fetchEvents() async {
    if (!AppConfig.useSupabase) return const [];

    final rows = await _supabase!
        .from('patogh_events')
        .select()
        .eq('published', true)
        .order('created_at', ascending: false);

    return (rows as List)
        .map(
          (row) => PatoghEvent.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  static Future<Map<String, String>> fetchMyReservations() async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return const {};

    final rows = await _supabase!
        .from('reservations')
        .select('event_id,status')
        .eq('user_id', userId);

    final result = <String, String>{};
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      result['${map['event_id']}'] = '${map['status']}';
    }
    return result;
  }

  static Future<String> reserveEvent(
    String eventId, {
    bool waitlistOnly = false,
  }) async {
    if (!AppConfig.useSupabase) {
      return waitlistOnly ? 'waitlist' : 'reserved';
    }

    final response = await _supabase!.rpc(
      'reserve_event',
      params: {'p_event_id': eventId, 'p_waitlist_only': waitlistOnly},
    );

    if (response is Map) {
      return '${response['status'] ?? 'reserved'}';
    }
    return 'reserved';
  }

  static Future<void> cancelReservation(String eventId) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;

    await _supabase!
        .from('reservations')
        .delete()
        .eq('user_id', userId)
        .eq('event_id', eventId);
  }

  static Future<void> setFavorite(String eventId, bool favorite) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;

    if (favorite) {
      await _supabase!.from('favorites').upsert({
        'user_id': userId,
        'event_id': eventId,
      });
    } else {
      await _supabase!
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);
    }
  }

  static Future<Set<String>> fetchFavorites() async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return <String>{};

    final rows = await _supabase!
        .from('favorites')
        .select('event_id')
        .eq('user_id', userId);

    return {for (final row in rows as List) '${(row as Map)['event_id']}'};
  }

  static Future<List<ChatMessage>> fetchMessages(String roomId) async {
    if (!AppConfig.useSupabase) return const [];

    final userId = currentUserId;

    final rows = await _supabase!
        .from('chat_messages')
        .select('user_id,text,created_at')
        .eq('room_id', roomId)
        .order('created_at');

    return (rows as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final created = DateTime.tryParse('${map['created_at']}');
      final time = created == null
          ? ''
          : '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

      return ChatMessage(
        text: (map['text'] as String?) ?? '',
        mine: '${map['user_id']}' == userId,
        time: time,
      );
    }).toList();
  }

  static Stream<List<ChatMessage>> watchMessages(String roomId) {
    if (!AppConfig.useSupabase) {
      return const Stream<List<ChatMessage>>.empty();
    }

    final userId = currentUserId;

    return _supabase!
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((rows) {
          return rows.map((map) {
            final created = DateTime.tryParse('${map['created_at']}');
            final time = created == null
                ? ''
                : '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

            return ChatMessage(
              text: (map['text'] as String?) ?? '',
              mine: '${map['user_id']}' == userId,
              time: time,
            );
          }).toList();
        });
  }

  static Future<void> sendMessage(String roomId, String text) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;

    await _supabase!.from('chat_messages').insert({
      'room_id': roomId,
      'user_id': userId,
      'text': text,
    });
  }

  static Future<void> createEvent(PatoghEvent event) async {
    if (!AppConfig.useSupabase) return;

    await _supabase!
        .from('patogh_events')
        .insert(event.toRemoteMap(hostId: currentUserId));
  }

  static Future<void> registerPushToken() async {
    final userId = currentUserId;
    if (!AppConfig.useFirebase || !AppConfig.useSupabase || userId == null) {
      return;
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final token = await messaging.getToken(
      vapidKey: kIsWeb && AppConfig.fcmVapidKey.isNotEmpty
          ? AppConfig.fcmVapidKey
          : null,
    );

    if (token == null || token.isEmpty) return;

    await _supabase!.from('device_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': kIsWeb ? 'web' : 'mobile',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<PaymentStartResult> createPayment({
    required PatoghEvent event,
  }) async {
    if (!AppConfig.usePaymentApi) {
      return const PaymentStartResult(demo: true);
    }

    final response = await http.post(
      Uri.parse('${AppConfig.paymentApiBaseUrl}/payment-create'),
      headers: {
        'content-type': 'application/json',
        if (_supabase?.auth.currentSession?.accessToken != null)
          'authorization':
              'Bearer ${_supabase!.auth.currentSession!.accessToken}',
      },
      body: jsonEncode({
        'event_id': event.id,
        'amount': event.finalPrice,
        'callback_url': Uri.base
            .replace(
              queryParameters: {'payment': 'callback', 'event_id': event.id},
            )
            .toString(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('خطا در ساخت پرداخت: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    return PaymentStartResult(
      url: body['payment_url'] as String?,
      reference: body['reference'] as String?,
    );
  }

  static Future<List<Map<String, dynamic>>> fetchCategoriesV6() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!
        .from('categories')
        .select()
        .order('sort_order');
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<void> saveCategoryV6(Map<String, dynamic> category) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.from('categories').upsert(category);
  }

  static Future<void> toggleCategoryV6(String id, bool active) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!
        .from('categories')
        .update({'is_active': active})
        .eq('id', id);
  }

  static Future<void> requestRoleV6(String role, String note) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;
    await _supabase!.from('role_requests').insert({
      'user_id': userId,
      'requested_role': role,
      'note': note,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchRoleRequestsV6() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!
        .from('role_requests')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<void> reviewRoleRequestV6(String id, bool approve) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.rpc(
      'approve_role_request',
      params: {'p_request_id': id, 'p_approve': approve},
    );
  }

  static Future<List<Map<String, dynamic>>> fetchTimelineV6() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!
        .from('timeline_posts')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<void> addTimelinePostV6({
    required String text,
    required String authorName,
    required String roleLabel,
    required String eventTitle,
    String? eventId,
  }) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;
    await _supabase!.from('timeline_posts').insert({
      'user_id': userId,
      'event_id': eventId,
      'text': text,
      'author_name': authorName,
      'role_label': roleLabel,
      'event_title': eventTitle,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchStoriesV6() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!
        .from('stories')
        .select()
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<void> addStoryV6({
    required String title,
    required String subtitle,
    required String ownerName,
    required String ownerRole,
  }) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;
    await _supabase!.from('stories').insert({
      'user_id': userId,
      'title': title,
      'subtitle': subtitle,
      'owner_name': ownerName,
      'owner_role': ownerRole,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchCommunitiesV6() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!
        .from('communities')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<void> createCommunityV6({
    required String title,
    required String description,
    required String type,
    required String ownerName,
  }) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;
    final row = await _supabase!
        .from('communities')
        .insert({
          'owner_id': userId,
          'title': title,
          'description': description,
          'community_type': type,
          'owner_name': ownerName,
          'member_count': 1,
        })
        .select('id')
        .single();
    await _supabase!.from('community_members').insert({
      'community_id': row['id'],
      'user_id': userId,
      'member_role': 'owner',
    });
  }
}
