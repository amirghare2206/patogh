import 'package:flutter_test/flutter_test.dart';
import 'package:patogh/models/media_attachment.dart';
import 'package:patogh/services/media_policy.dart';
void main() {
  test('post/story media max is 20', () { expect(MediaPolicy.validatePostStory(existingItems: 20, kind: MediaKind.image), isNotNull); });
  test('post/story video max is 2 minutes', () { expect(MediaPolicy.validatePostStory(existingItems: 0, kind: MediaKind.video, durationMs: const Duration(minutes: 2, seconds: 1).inMilliseconds), isNotNull); });
  test('community video max is 10 MiB', () { expect(MediaPolicy.validateCommunity(kind: MediaKind.video, sizeBytes: 10 * 1024 * 1024 + 1), isNotNull); expect(MediaPolicy.validateCommunity(kind: MediaKind.image, sizeBytes: 30 * 1024 * 1024), isNull); });
}
