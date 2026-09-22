import os, sys

platform = (sys.argv[1] if len(sys.argv) > 1 else 'common').lower()
required = [
    'PROD_SUPABASE_URL',
    'PROD_SUPABASE_ANON_KEY',
    'PAYMENT_API_BASE_URL',
    'FIREBASE_API_KEY',
    'FIREBASE_APP_ID',
    'FIREBASE_MESSAGING_SENDER_ID',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_STORAGE_BUCKET',
]
if platform == 'android':
    required += [
        'ANDROID_KEYSTORE_BASE64',
        'ANDROID_STORE_PASSWORD',
        'ANDROID_KEY_PASSWORD',
        'ANDROID_KEY_ALIAS',
    ]
elif platform == 'ios':
    required += [
        'IOS_CERTIFICATE_P12_BASE64',
        'IOS_CERTIFICATE_PASSWORD',
        'IOS_PROVISION_PROFILE_BASE64',
        'IOS_KEYCHAIN_PASSWORD',
        'APPLE_TEAM_ID',
    ]

missing = [k for k in required if not os.environ.get(k, '').strip()]
if missing:
    print('PUBLIC_RELEASE_BLOCKED: missing required secrets:')
    for key in missing:
        print(f' - {key}')
    raise SystemExit(2)

print(f'Public release preflight OK for {platform}.')
