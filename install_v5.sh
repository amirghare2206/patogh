#!/usr/bin/env bash
set -euo pipefail

echo "== Patogh v5 setup =="

flutter pub add \
  shared_preferences \
  supabase_flutter \
  firebase_core \
  firebase_messaging \
  http \
  url_launcher

dart format lib test

flutter analyze
flutter test

flutter build web \
  --release \
  --base-href "/patogh/" \
  --no-web-resources-cdn

echo
echo "Demo build completed successfully."
echo "For production, configure Supabase/Firebase/payment keys and build with dart-defines."
