import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickedProfileImage {
  final XFile file;
  final Uint8List bytes;
  final String mimeType;

  const PickedProfileImage({
    required this.file,
    required this.bytes,
    required this.mimeType,
  });

  String get fileName => file.name;
}

class ProfileAvatarImage extends StatelessWidget {
  final String? avatarUrl;
  final Uint8List? previewBytes;
  final double radius;

  const ProfileAvatarImage({
    super.key,
    this.avatarUrl,
    this.previewBytes,
    this.radius = 44,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFD9E8), Color(0xFFDCD8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.face_retouching_natural_rounded,
        size: radius * 1.05,
        color: const Color(0xFF65558C),
      ),
    );

    Widget image;
    if (previewBytes != null) {
      image = Image.memory(
        previewBytes!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } else if (avatarUrl != null && avatarUrl!.startsWith('data:image/')) {
      try {
        final comma = avatarUrl!.indexOf(',');
        final bytes = base64Decode(avatarUrl!.substring(comma + 1));
        image = Image.memory(
          bytes,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback(),
        );
      } catch (_) {
        image = fallback();
      }
    } else if (avatarUrl != null &&
        (avatarUrl!.startsWith('https://') ||
            avatarUrl!.startsWith('http://'))) {
      image = Image.network(
        avatarUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } else {
      image = fallback();
    }

    return ClipOval(
      child: SizedBox(width: radius * 2, height: radius * 2, child: image),
    );
  }
}

class ProfileAvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final Uint8List? previewBytes;
  final ValueChanged<PickedProfileImage> onPicked;
  final bool enabled;

  const ProfileAvatarPicker({
    super.key,
    this.avatarUrl,
    this.previewBytes,
    required this.onPicked,
    this.enabled = true,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    if (!enabled) return;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 900,
        maxHeight: 900,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('EMPTY_IMAGE');
      }
      final extension = file.name.split('.').last.toLowerCase();
      final mimeType =
          file.mimeType ??
          (extension == 'png'
              ? 'image/png'
              : extension == 'webp'
              ? 'image/webp'
              : 'image/jpeg');
      onPicked(
        PickedProfileImage(file: file, bytes: bytes, mimeType: mimeType),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عکس انتخاب نشد. دسترسی گالری یا دوربین را بررسی کن.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB8D2),
                      Color(0xFFB9B4FF),
                      Color(0xFFA9E9D8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB9B4FF).withAlpha(75),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ProfileAvatarImage(
                  avatarUrl: avatarUrl,
                  previewBytes: previewBytes,
                  radius: 48,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Color(0xFF665A91),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'عکس پروفایلت رو انتخاب کن (اختیاری)',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: enabled
                  ? () => _pick(context, ImageSource.gallery)
                  : null,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('انتخاب از گالری'),
            ),
            OutlinedButton.icon(
              onPressed: enabled
                  ? () => _pick(context, ImageSource.camera)
                  : null,
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('دوربین'),
            ),
          ],
        ),
      ],
    );
  }
}
