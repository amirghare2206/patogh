#!/usr/bin/env bash
set -euo pipefail

echo "== Patogh v11 final-today setup =="

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
echo "Patogh v11 Demo build completed successfully."
echo "Production migration: backend/supabase/v11_time_occasion_memorial.sql"
