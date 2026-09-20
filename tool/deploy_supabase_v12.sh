#!/usr/bin/env bash
set -euo pipefail
: "${SUPABASE_PROJECT_REF:?Set SUPABASE_PROJECT_REF}"

CLI="npx supabase@latest"

echo "Linking Supabase project..."
$CLI link --project-ref "$SUPABASE_PROJECT_REF"

echo "Apply backend/supabase/release_bootstrap_v12.sql in SQL Editor first."
echo "Deploying authenticated client functions..."
for fn in validate-media get-media-url delete-account; do
  $CLI functions deploy "$fn" --project-ref "$SUPABASE_PROJECT_REF"
done

echo "Deploying Send SMS Auth Hook without platform JWT verification."
echo "The function validates the Standard Webhooks signature itself."
$CLI functions deploy send-sms-hook --project-ref "$SUPABASE_PROJECT_REF" --no-verify-jwt

echo "Done. Configure SEND_SMS_HOOK_SECRET and SMS provider secrets only for Production."
