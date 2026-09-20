import 'package:patogh/models/media_attachment.dart';

class MediaPolicy {
  static const int maxPostStoryItems = 20;
  static const Duration maxPostStoryVideoDuration = Duration(minutes: 2);
  static const int maxCommunityVideoBytes = 10 * 1024 * 1024;

  static String? validatePostStory({
    required int existingItems,
    required MediaKind kind,
    int? durationMs,
  }) {
    if (existingItems >= maxPostStoryItems) {
      return 'در هر پست یا استوری حداکثر ۲۰ عکس/ویدئو مجاز است.';
    }
    if (kind == MediaKind.video &&
        durationMs != null &&
        durationMs > maxPostStoryVideoDuration.inMilliseconds) {
      return 'ویدئوی پست و استوری حداکثر ۲ دقیقه می‌تواند باشد.';
    }
    return null;
  }

  static String? validateCommunity({
    required MediaKind kind,
    required int sizeBytes,
  }) {
    if (kind == MediaKind.video && sizeBytes > maxCommunityVideoBytes) {
      return 'ویدئوی گروه و کانال حداکثر ۱۰ مگابایت می‌تواند باشد.';
    }
    return null;
  }
}
