#!/usr/bin/env bash
set -euo pipefail

echo "== Patogh v12 market/multi-user setup =="
flutter pub add shared_preferences supabase_flutter firebase_core firebase_messaging http url_launcher image_picker file_picker video_player
python3 tool/configure_android_release.py
python3 tool/prepare_pubspec_release.py
python3 tool/preflight_v12.py

cat >> .gitignore <<'EOF'
# Patogh release secrets
config/staging.json
config/production.json
android/key.properties
android/app/*.jks
android/app/*.keystore
EOF

dart format lib test
flutter analyze
flutter test
flutter build web --release --base-href "/patogh/" --no-web-resources-cdn

echo "v12 code checks complete. For shared multi-user testing configure Supabase and build with PATOGH_MODE=staging."
