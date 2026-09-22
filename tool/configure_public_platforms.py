from pathlib import Path
import os, re, shutil

root = Path.cwd()
brand = root / 'assets/branding/platform'

# ---------- Android ----------
android_app = root / 'android/app'
if android_app.exists():
    for src_dir in (brand / 'android').glob('mipmap-*'):
        dst = android_app / 'src/main/res' / src_dir.name
        dst.mkdir(parents=True, exist_ok=True)
        for f in src_dir.glob('*.png'):
            shutil.copy2(f, dst / f.name)

    manifest = android_app / 'src/main/AndroidManifest.xml'
    if manifest.exists():
        text = manifest.read_text()
        permissions = [
            'android.permission.INTERNET',
            'android.permission.ACCESS_COARSE_LOCATION',
            'android.permission.ACCESS_FINE_LOCATION',
            'android.permission.CAMERA',
            'android.permission.RECORD_AUDIO',
            'android.permission.POST_NOTIFICATIONS',
            'android.permission.READ_MEDIA_IMAGES',
            'android.permission.READ_MEDIA_VIDEO',
        ]
        insertion = ''
        for perm in permissions:
            if perm not in text:
                insertion += f'\n    <uses-permission android:name="{perm}" />'
        if insertion:
            pos = text.find('>') + 1
            text = text[:pos] + insertion + text[pos:]
        text = re.sub(r'android:label="[^"]*"', 'android:label="پاتوق"', text)
        text = text.replace('android:usesCleartextTraffic="true"', 'android:usesCleartextTraffic="false"')
        manifest.write_text(text)

# ---------- iOS ----------
ios = root / 'ios'
if ios.exists():
    appicons = ios / 'Runner/Assets.xcassets/AppIcon.appiconset'
    appicons.mkdir(parents=True, exist_ok=True)
    for f in (brand / 'ios').glob('*.png'):
        shutil.copy2(f, appicons / f.name)
    if (brand / 'ios/Contents.json').exists():
        shutil.copy2(brand / 'ios/Contents.json', appicons / 'Contents.json')

    plist = ios / 'Runner/Info.plist'
    if plist.exists():
        text = plist.read_text()
        # Brand display name and permission descriptions required by public features.
        text = re.sub(
            r'<key>CFBundleDisplayName</key>\s*<string>.*?</string>',
            '<key>CFBundleDisplayName</key>\n\t<string>پاتوق</string>',
            text,
            flags=re.S,
        )
        additions = {
            'NSPhotoLibraryUsageDescription': 'برای انتخاب و اشتراک عکس و ویدیو در پاتوق به دسترسی عکس‌ها نیاز داریم.',
            'NSCameraUsageDescription': 'برای ثبت عکس و ویدیو در رویدادها و استوری‌ها به دوربین نیاز داریم.',
            'NSMicrophoneUsageDescription': 'برای ثبت صدا و ویدیو در گروه‌ها و خاطرات رویداد به میکروفن نیاز داریم.',
            'NSLocationWhenInUseUsageDescription': 'برای پیشنهاد رویدادهای نزدیک و تجربه‌های مسیرمحور، مکان فقط هنگام استفاده از این قابلیت دریافت می‌شود.',
        }
        for key, value in additions.items():
            if f'<key>{key}</key>' not in text:
                text = text.replace('</dict>', f'\t<key>{key}</key>\n\t<string>{value}</string>\n</dict>', 1)
        if '<key>UIBackgroundModes</key>' not in text:
            text = text.replace(
                '</dict>',
                '\t<key>UIBackgroundModes</key>\n\t<array>\n\t\t<string>remote-notification</string>\n\t</array>\n</dict>',
                1,
            )
        plist.write_text(text)

    pbx = ios / 'Runner.xcodeproj/project.pbxproj'
    if pbx.exists():
        text = pbx.read_text()
        text = re.sub(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;', 'PRODUCT_BUNDLE_IDENTIFIER = ir.patogh.app;', text)
        text = re.sub(r'IPHONEOS_DEPLOYMENT_TARGET = [^;]+;', 'IPHONEOS_DEPLOYMENT_TARGET = 15.0;', text)
        team = os.environ.get('APPLE_TEAM_ID', '').strip()
        if team:
            if 'DEVELOPMENT_TEAM =' in text:
                text = re.sub(r'DEVELOPMENT_TEAM = [^;]*;', f'DEVELOPMENT_TEAM = {team};', text)
            else:
                text = text.replace('PRODUCT_BUNDLE_IDENTIFIER = ir.patogh.app;', f'PRODUCT_BUNDLE_IDENTIFIER = ir.patogh.app;\n\t\t\t\tDEVELOPMENT_TEAM = {team};')
        pbx.write_text(text)

    podfile = ios / 'Podfile'
    if podfile.exists():
        pod = podfile.read_text()
        if re.search(r"^platform :ios, '.*'", pod, flags=re.M):
            pod = re.sub(r"^platform :ios, '.*'", "platform :ios, '15.0'", pod, flags=re.M)
        elif '# platform :ios' in pod:
            pod = pod.replace("# platform :ios, '13.0'", "platform :ios, '15.0'")
        podfile.write_text(pod)

print('Public Android/iOS branding and permissions prepared')
