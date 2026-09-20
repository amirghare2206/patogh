from pathlib import Path
import re, shutil
root=Path.cwd()
app=root/'android/app'
if not app.exists(): raise SystemExit('android/app not found. Run from Flutter project root.')

# Package/namespace and SDK target. Android 16 / API 36 keeps the package ready
# for current 2026 Android-store requirements as well as Bazaar testing.
kts=app/'build.gradle.kts'
groovy=app/'build.gradle'
if kts.exists():
    text=kts.read_text()
    if 'import java.util.Properties' not in text:
        text='import java.util.Properties\nimport java.io.FileInputStream\n\n'+text
    prefix='''\nval keystoreProperties = Properties()\nval keystorePropertiesFile = rootProject.file("key.properties")\nif (keystorePropertiesFile.exists()) {\n    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n}\n\n'''
    if 'val keystoreProperties = Properties()' not in text:
        idx=text.find('android {')
        text=text[:idx]+prefix+text[idx:]
    text=re.sub(r'namespace\s*=\s*"[^"]+"','namespace = "ir.patogh.app"',text)
    text=re.sub(r'applicationId\s*=\s*"[^"]+"','applicationId = "ir.patogh.app"',text)
    text=re.sub(r'compileSdk\s*=\s*[^\n]+','compileSdk = 36',text)
    text=re.sub(r'targetSdk\s*=\s*[^\n]+','targetSdk = 36',text)
    if 'create("release")' not in text:
        marker='    buildTypes {'
        block='''    signingConfigs {\n        create("release") {\n            if (keystorePropertiesFile.exists()) {\n                keyAlias = keystoreProperties["keyAlias"] as String\n                keyPassword = keystoreProperties["keyPassword"] as String\n                storeFile = file(keystoreProperties["storeFile"] as String)\n                storePassword = keystoreProperties["storePassword"] as String\n            }\n        }\n    }\n\n'''
        text=text.replace(marker,block+marker)
    text=text.replace('signingConfig = signingConfigs.getByName("debug")','signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")')
    kts.write_text(text)
elif groovy.exists():
    text=groovy.read_text()
    if 'def keystoreProperties = new Properties()' not in text:
        prefix='''def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

'''
        text=prefix+text
    text=re.sub(r'namespace\s+["\'][^"\']+["\']','namespace "ir.patogh.app"',text)
    text=re.sub(r'applicationId\s+["\'][^"\']+["\']','applicationId "ir.patogh.app"',text)
    text=re.sub(r'compileSdk(?:Version)?\s+(?:flutter\.compileSdkVersion|\d+)','compileSdk 36',text)
    text=re.sub(r'targetSdk(?:Version)?\s+(?:flutter\.targetSdkVersion|\d+)','targetSdk 36',text)
    if 'signingConfigs {' not in text or "keystoreProperties['keyAlias']" not in text:
        marker='    buildTypes {'
        block='''    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }

'''
        if marker in text:
            text=text.replace(marker,block+marker,1)
    text=text.replace('signingConfig signingConfigs.debug', "signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : signingConfigs.debug")
    groovy.write_text(text)
else:
    raise SystemExit('No Android app Gradle file found.')

# Move/rewrite MainActivity package so relative manifest activity resolves.
for ext in ('kt','java'):
    for src in list((app/'src/main').rglob(f'MainActivity.{ext}')):
        body=src.read_text()
        body=re.sub(r'^package\s+[^\n;]+[;]?','package ir.patogh.app' + (';' if ext=='java' else ''),body,flags=re.M)
        dest=app/'src/main'/('kotlin' if ext=='kt' else 'java')/'ir/patogh/app'/f'MainActivity.{ext}'
        dest.parent.mkdir(parents=True,exist_ok=True)
        dest.write_text(body)
        if src.resolve()!=dest.resolve(): src.unlink()

manifest=app/'src/main/AndroidManifest.xml'
if manifest.exists():
    text=manifest.read_text()
    if 'android.permission.INTERNET' not in text:
        text=text.replace('<manifest', '<manifest', 1)
        pos=text.find('>')+1
        text=text[:pos]+'\n    <uses-permission android:name="android.permission.INTERNET" />'+text[pos:]
    text=re.sub(r'android:label="[^"]*"','android:label="پاتوق"',text)
    text=text.replace('android:usesCleartextTraffic="true"','android:usesCleartextTraffic="false"')
    manifest.write_text(text)

print('Android release config prepared: ir.patogh.app, targetSdk 36')
