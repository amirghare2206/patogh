#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f pubspec.yaml ]]; then
  echo "این اسکریپت باید از ریشه Flutter repo پاتوق اجرا شود (pubspec.yaml پیدا نشد)."
  exit 2
fi

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
DART_BIN="${DART_BIN:-dart}"

if [[ ! -d android ]]; then
  "$FLUTTER_BIN" create . --platforms=android --project-name patogh --org ir.patogh
fi

# ساخت iOS نیاز به Xcode ندارد ولی Build نهایی فقط روی macOS انجام می‌شود.
if [[ ! -d ios ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    "$FLUTTER_BIN" create . --platforms=ios --project-name patogh --org ir.patogh
  else
    echo "ios/ در این ماشین ساخته نمی‌شود؛ Workflow build-public-ios.yml آن را روی macOS runner می‌سازد."
  fi
fi

python3 tool/prepare_public_release.py
python3 tool/configure_android_release.py
python3 tool/configure_public_platforms.py
"$FLUTTER_BIN" pub get
"$DART_BIN" format lib
"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" test

echo "پاتوق v13 Public Release overlay آماده شد."
