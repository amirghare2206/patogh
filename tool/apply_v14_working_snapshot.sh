#!/usr/bin/env bash
set -euo pipefail

# Safe overlay helper. It never commits or pushes and only permits v14-test.
# Usage from the existing repo root:
#   bash /path/to/snapshot/tool/apply_v14_working_snapshot.sh /path/to/extracted/snapshot

if [ ! -d .git ]; then
  echo "STOP: run this from the root of the existing Git repository."
  exit 2
fi
branch="$(git branch --show-current)"
if [ "$branch" != "v14-test" ]; then
  echo "STOP: current branch is '$branch'; switch to v14-test first."
  exit 2
fi
if [ "$#" -ne 1 ] || [ ! -f "$1/pubspec.yaml" ]; then
  echo "Usage: bash tool/apply_v14_working_snapshot.sh /path/to/extracted/snapshot"
  exit 2
fi
src="$(cd "$1" && pwd)"
dest="$(pwd)"
if [ "$src" = "$dest" ]; then
  echo "STOP: source snapshot must be extracted into a separate directory."
  exit 2
fi

stamp="$(date +%Y%m%d_%H%M%S)"
backup="$HOME/patogh_pre_v14_overlay_${stamp}.tar.gz"
echo "Creating local backup at: $backup"
tar -czf "$backup" --exclude='./.git' --exclude='./.dart_tool' --exclude='./build' .

if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude='.git/' \
    --exclude='secret.txt' \
    --exclude='keystore.base64' \
    --exclude='key.properties' \
    --exclude='.env' \
    --exclude='.env.*' \
    --exclude='*.jks' \
    --exclude='*.keystore' \
    --exclude='*.p12' \
    --exclude='*.pfx' \
    --exclude='*.pem' \
    "$src/" "$dest/"
else
  echo "STOP: rsync is required; no files were copied. Install/use rsync, then retry."
  exit 2
fi

git diff --check
python3 tool/preflight_v14_working.py

echo "Overlay complete. No commit or push was performed."
echo "Backup: $backup"
echo "Review git diff and run flutter analyze/test before committing."
