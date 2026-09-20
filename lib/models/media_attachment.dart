enum MediaKind { image, video, audio }

class MediaAttachment {
  final String id;
  final MediaKind kind;
  final String mimeType;
  final int sizeBytes;
  final int? durationMs;
  final String? storagePath;
  final String? url;

  const MediaAttachment({
    required this.id,
    required this.kind,
    required this.mimeType,
    required this.sizeBytes,
    this.durationMs,
    this.storagePath,
    this.url,
  });

  factory MediaAttachment.fromMap(Map<String, dynamic> map) {
    final type = '${map['media_type'] ?? map['kind'] ?? 'image'}';
    return MediaAttachment(
      id: '${map['id']}',
      kind: switch (type) {
        'video' => MediaKind.video,
        'audio' => MediaKind.audio,
        _ => MediaKind.image,
      },
      mimeType: (map['mime_type'] as String?) ?? 'application/octet-stream',
      sizeBytes: (map['size_bytes'] as num?)?.toInt() ?? 0,
      durationMs: (map['duration_ms'] as num?)?.toInt(),
      storagePath: map['storage_path'] as String?,
      url: map['signed_url'] as String?,
    );
  }

  MediaAttachment copyWith({String? url}) => MediaAttachment(
    id: id,
    kind: kind,
    mimeType: mimeType,
    sizeBytes: sizeBytes,
    durationMs: durationMs,
    storagePath: storagePath,
    url: url ?? this.url,
  );
}
