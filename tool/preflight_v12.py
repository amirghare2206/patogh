from pathlib import Path
import re, sys

root = Path(__file__).resolve().parents[1]
errors=[]
required = [
    'lib/main.dart','lib/app.dart','lib/state/app_state.dart',
    'lib/services/media_service.dart','lib/services/media_policy.dart',
    'backend/supabase/release_bootstrap_v12.sql',
    'backend/supabase/STAGING_SEED_V12.sql',
    'backend/supabase/functions/validate-media/index.ts',
    'backend/supabase/functions/get-media-url/index.ts',
    '.github/workflows/build-staging-apk.yml',
    '.github/workflows/build-market-release.yml',
]
for rel in required:
    if not (root/rel).exists(): errors.append(f'MISSING {rel}')

for dart in (root/'lib').rglob('*.dart'):
    text=dart.read_text(encoding='utf-8')
    for m in re.finditer(r"import\s+'package:patogh/([^']+)'", text):
        target=root/'lib'/m.group(1)
        if not target.exists(): errors.append(f'{dart.relative_to(root)} -> missing {target.relative_to(root)}')

for rel in ['lib/services/media_service.dart','lib/services/platform_services.dart']:
    text=(root/rel).read_text(encoding='utf-8')
    if re.search(r'\bresponse\.status\b', text):
        errors.append(f'{rel}: unsupported FunctionResponse.status usage')

policy=(root/'lib/services/media_policy.dart').read_text(encoding='utf-8')
for marker in ['maxPostStoryItems = 20','Duration(minutes: 2)','10 * 1024 * 1024']:
    if marker not in policy: errors.append(f'media policy marker missing: {marker}')

if errors:
    print('V12 PREFLIGHT FAILED')
    for e in errors: print('-', e)
    sys.exit(1)
print('V12 PREFLIGHT OK')
