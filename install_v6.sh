#!/usr/bin/env bash
set -euo pipefail

echo "== Patogh v6 setup =="

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
flutter build web --release --base-href "/patogh/" --no-web-resources-cdn

echo
echo "Patogh v6 demo build completed successfully."
echo "For production: run backend/supabase/schema.sql then v6_roles_social.sql and configure the existing v5 production secrets."
