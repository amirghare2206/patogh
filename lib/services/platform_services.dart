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
    if (!AppConfig.useSupabase) {
      if (AppConfig.isProduction) {
        throw StateError('AUTH_BACKEND_NOT_CONFIGURED');
      }
      return;
    }
    if (AppConfig.useStagingAnonymousAuth) return;
    await _supabase!.auth.signInWithOtp(phone: normalizeIranPhone(phone));
  }

  static Future<void> verifyOtp(String phone, String code) async {
    if (!AppConfig.useSupabase) {
      if (AppConfig.isProduction) {
        throw StateError('AUTH_BACKEND_NOT_CONFIGURED');
      }
      if (code != '1234') {
        throw Exception('کد آزمایشی صحیح 1234 است.');
      }
      return;
    }

    if (AppConfig.useStagingAnonymousAuth) {
      if (code != '1234') {
        throw Exception('کد تست چندکاربره 1234 است.');
      }

      final normalizedPhone = normalizeIranPhone(phone);
      final currentUser = _supabase!.auth.currentUser;
      final currentTesterPhone = currentUser?.userMetadata?['tester_phone']
          ?.toString();

      if (currentUser == null || currentTesterPhone != normalizedPhone) {
        if (currentUser != null) {
          await _supabase!.auth.signOut();
        }
        await _supabase!.auth.signInAnonymously(
          data: {'tester_phone': normalizedPhone},
        );
      }

      await _supabase!.rpc(
        'ensure_profile_v12',
        params: {'p_phone': normalizedPhone},
      );
      return;
    }

    await _supabase!.auth.verifyOTP(
      phone: normalizeIranPhone(phone),
      token: code,
      type: OtpType.sms,
    );
  }

  static Future<void> signOut() async {
    if (!AppConfig.useSupabase) return;

    // در Staging نشست Anonymous حفظ می‌شود تا ورود مجدد با همان شماره
    // همان شناسه آزمایشی را نگه دارد. Production همیشه Sign out واقعی است.
    if (AppConfig.useStagingAnonymousAuth) return;

    await _supabase!.auth.signOut();
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
    if ((row['onboarding_completed'] as bool?) != true) return null;

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

    final authUser = _supabase!.auth.currentUser;
    final profilePhone =
        authUser?.phone ?? authUser?.userMetadata?['tester_phone']?.toString();

    await _supabase!.from('profiles').upsert({
      'id': userId,
      'phone': profilePhone,
      'name': profile.name,
      'age': profile.age,
      'city': profile.city,
      'interests': profile.interests,
      'show_age': profile.showAge,
      'allow_chat': profile.allowChat,
      'role': profile.role.key,
      'onboarding_completed': true,
      'terms_accepted_at': DateTime.now().toIso8601String(),
      'terms_version': 'v12-1',
      'privacy_version': 'v12-1',
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
    int? amount,
  }) async {
    if (!AppConfig.usePaymentApi) {
      if (AppConfig.isProduction) {
        throw StateError('PAYMENT_NOT_CONFIGURED');
      }
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
        'amount': amount ?? event.finalPrice,
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

  static Future<List<Map<String, dynamic>>> fetchBannersV13() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!
        .from('banners')
        .select(
          'id,title,subtitle,media_url,action_label,sponsored,audience_rules,priority,banner_placements(placement)',
        )
        .eq('active', true)
        .order('priority', ascending: false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<String?> saveBannerV13({
    required String title,
    required String subtitle,
    required String placement,
    required String audience,
    required bool sponsored,
    String? imageUrl,
  }) async {
    if (!AppConfig.useSupabase) return null;
    final row = await _supabase!
        .from('banners')
        .insert({
          'title': title,
          'subtitle': subtitle,
          'media_url': imageUrl?.trim().isEmpty == true
              ? null
              : imageUrl?.trim(),
          'action_label': 'مشاهده',
          'action_type': 'open',
          'sponsored': sponsored,
          'audience_rules': {'label': audience},
          'active': true,
        })
        .select('id')
        .single();
    final id = '${row['id']}';
    await _supabase!.from('banner_placements').upsert({
      'banner_id': id,
      'placement': placement,
    });
    return id;
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

  static Future<List<String>> fetchMyRolesV12() async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return const ['participant'];
    final rows = await _supabase!
        .from('user_roles')
        .select('role')
        .eq('user_id', userId)
        .eq('status', 'active');
    final roles = <String>{'participant'};
    for (final row in rows as List) {
      roles.add('${(row as Map)['role']}');
    }
    return roles.toList();
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
    final rows = await _supabase!.rpc('list_timeline_feed_v12');
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<String?> createTimelinePostV12({
    required String text,
    required String authorName,
    required String roleLabel,
    required String eventTitle,
    String? eventId,
  }) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return null;
    final row = await _supabase!
        .from('timeline_posts')
        .insert({
          'user_id': userId,
          'event_id': eventId,
          'text': text,
          'author_name': authorName,
          'role_label': roleLabel,
          'event_title': eventTitle,
        })
        .select('id')
        .single();
    return '${row['id']}';
  }

  static Future<void> attachMediaToPostV12(
    String postId,
    String assetId,
    int sortOrder,
  ) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.from('timeline_post_media').insert({
      'post_id': postId,
      'media_id': assetId,
      'sort_order': sortOrder,
    });
  }

  static Future<void> toggleTimelineLikeV12(String postId) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.rpc(
      'toggle_timeline_like_v12',
      params: {'p_post_id': postId},
    );
  }

  static Future<List<Map<String, dynamic>>> fetchStoriesV6() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!.rpc('list_active_stories_v12');
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<String?> createStoryV12({
    required String title,
    required String subtitle,
    required String ownerName,
    required String ownerRole,
  }) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return null;
    final row = await _supabase!
        .from('stories')
        .insert({
          'user_id': userId,
          'title': title,
          'subtitle': subtitle,
          'owner_name': ownerName,
          'owner_role': ownerRole,
        })
        .select('id')
        .single();
    return '${row['id']}';
  }

  static Future<void> attachMediaToStoryV12(
    String storyId,
    String assetId,
    int sortOrder,
  ) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.from('story_media').insert({
      'story_id': storyId,
      'media_id': assetId,
      'sort_order': sortOrder,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchCommunitiesV6() async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!.rpc('list_communities_v12');
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<String?> createCommunityV12({
    required String title,
    required String description,
    required String type,
    required String ownerName,
  }) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return null;
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
    final id = '${row['id']}';
    await _supabase!.from('community_members').insert({
      'community_id': id,
      'user_id': userId,
      'member_role': 'owner',
    });
    return id;
  }

  static Future<void> toggleCommunityMembershipV12(String communityId) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.rpc(
      'toggle_community_membership_v12',
      params: {'p_community_id': communityId},
    );
  }

  static Future<List<Map<String, dynamic>>> fetchChatRowsV12(
    String roomId,
  ) async {
    if (!AppConfig.useSupabase) return const [];
    final rows = await _supabase!.rpc(
      'list_chat_messages_v12',
      params: {'p_room_id': roomId},
    );
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  static Future<List<ChatMessage>> fetchMessages(String roomId) async {
    if (!AppConfig.useSupabase) return const [];
    final userId = currentUserId;
    final rows = await _supabase!.rpc(
      'list_chat_messages_v12',
      params: {'p_room_id': roomId},
    );
    return (rows as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final created = DateTime.tryParse('${map['created_at']}');
      final time = created == null
          ? ''
          : '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';
      return ChatMessage(
        id: '${map['id']}',
        userId: map['user_id'] as String?,
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
        .map(
          (rows) => rows.map((map) {
            final created = DateTime.tryParse('${map['created_at']}');
            final time = created == null
                ? ''
                : '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';
            return ChatMessage(
              id: '${map['id']}',
              userId: map['user_id'] as String?,
              text: (map['text'] as String?) ?? '',
              mine: '${map['user_id']}' == userId,
              time: time,
            );
          }).toList(),
        );
  }

  static Future<String?> sendMessageV12(String roomId, String text) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return null;
    final row = await _supabase!
        .from('chat_messages')
        .insert({'room_id': roomId, 'user_id': userId, 'text': text})
        .select('id')
        .single();
    return '${row['id']}';
  }

  static Future<void> attachMediaToMessageV12(
    String messageId,
    String assetId,
    int sortOrder,
  ) async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.from('chat_message_media').insert({
      'message_id': messageId,
      'media_id': assetId,
      'sort_order': sortOrder,
    });
  }

  static Future<void> reportContentV12({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null) return;
    await _supabase!.from('moderation_reports').insert({
      'reporter_id': userId,
      'reason': reason,
      'details': '$targetType:$targetId',
    });
  }

  static Future<void> blockUserV12(String blockedUserId) async {
    final userId = currentUserId;
    if (!AppConfig.useSupabase || userId == null || blockedUserId == userId) {
      return;
    }
    await _supabase!.from('user_blocks').upsert({
      'blocker_id': userId,
      'blocked_id': blockedUserId,
    });
  }

  static Future<void> deleteMyAccountV12() async {
    if (!AppConfig.useSupabase) return;
    await _supabase!.functions.invoke('delete-account');
  }

  static Future<void> addTimelinePostV6({
    required String text,
    required String authorName,
    required String roleLabel,
    required String eventTitle,
    String? eventId,
  }) async {
    await createTimelinePostV12(
      text: text,
      authorName: authorName,
      roleLabel: roleLabel,
      eventTitle: eventTitle,
      eventId: eventId,
    );
  }

  static Future<void> addStoryV6({
    required String title,
    required String subtitle,
    required String ownerName,
    required String ownerRole,
  }) async {
    await createStoryV12(
      title: title,
      subtitle: subtitle,
      ownerName: ownerName,
      ownerRole: ownerRole,
    );
  }

  static Future<void> createCommunityV6({
    required String title,
    required String description,
    required String type,
    required String ownerName,
  }) async {
    await createCommunityV12(
      title: title,
      description: description,
      type: type,
      ownerName: ownerName,
    );
  }

  static Future<void> sendMessage(String roomId, String text) async {
    await sendMessageV12(roomId, text);
  }
}
