import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/models/media_attachment.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/services/video_duration_probe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectedMedia {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final MediaKind kind;
  final int? durationMs;
  const SelectedMedia({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.kind,
    this.durationMs,
  });
  int get sizeBytes => bytes.length;
}

class MediaService {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<SelectedMedia>> pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 92);
    final output = <SelectedMedia>[];
    for (final file in files) {
      output.add(
        SelectedMedia(
          bytes: await file.readAsBytes(),
          fileName: file.name,
          mimeType: _mimeForName(file.name, fallback: 'image/jpeg'),
          kind: MediaKind.image,
        ),
      );
    }
    return output;
  }

  static Future<SelectedMedia?> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return null;
    return SelectedMedia(
      bytes: await file.readAsBytes(),
      fileName: file.name,
      mimeType: _mimeForName(file.name, fallback: 'video/mp4'),
      kind: MediaKind.video,
      durationMs: await probeVideoDurationMs(file.path),
    );
  }

  static Future<List<SelectedMedia>> pickAudio() async {
    final files = await FilePicker.pickFiles(type: FileType.audio);

    final output = <SelectedMedia>[];
    for (final file in files) {
      output.add(
        SelectedMedia(
          bytes: await file.readAsBytes(),
          fileName: file.name,
          mimeType: _mimeForName(file.name, fallback: 'audio/mpeg'),
          kind: MediaKind.audio,
        ),
      );
    }
    return output;
  }

  static Future<MediaAttachment> uploadValidated(
    SelectedMedia media, {
    required String scope,
  }) async {
    if (!AppConfig.useSupabase) {
      return MediaAttachment(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        kind: media.kind,
        mimeType: media.mimeType,
        sizeBytes: media.sizeBytes,
        durationMs: media.durationMs,
      );
    }
    final client = Supabase.instance.client;
    final userId = PlatformServices.currentUserId;
    if (userId == null) throw StateError('AUTH_REQUIRED');
    final safeName = media.fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final pendingPath =
        '$userId/${DateTime.now().microsecondsSinceEpoch}-$safeName';
    await client.storage
        .from('pending-media')
        .uploadBinary(
          pendingPath,
          media.bytes,
          fileOptions: FileOptions(contentType: media.mimeType, upsert: false),
        );
    final response = await client.functions.invoke(
      'validate-media',
      body: {
        'pending_path': pendingPath,
        'scope': scope,
        'client_duration_ms': media.durationMs,
      },
    );
    final attachment = MediaAttachment.fromMap(
      Map<String, dynamic>.from(response.data as Map),
    );
    return attachment.copyWith(url: await resolveSignedUrl(attachment.id));
  }

  static Future<String?> resolveSignedUrl(String assetId) async {
    if (!AppConfig.useSupabase) return null;
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-media-url',
        body: {'asset_id': assetId},
      );
      return Map<String, dynamic>.from(response.data as Map)['signed_url']
          as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<List<MediaAttachment>> hydrate(List<dynamic>? raw) async {
    if (raw == null || raw.isEmpty) return const [];
    final output = <MediaAttachment>[];
    for (final item in raw) {
      final a = MediaAttachment.fromMap(Map<String, dynamic>.from(item as Map));
      output.add(
        a.url == null ? a.copyWith(url: await resolveSignedUrl(a.id)) : a,
      );
    }
    return output;
  }

  static String _mimeForName(String name, {required String fallback}) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.m4a')) return 'audio/mp4';
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.ogg')) return 'audio/ogg';
    if (lower.endsWith('.mp3')) return 'audio/mpeg';
    return fallback;
  }
}
