from pathlib import Path
import os, re

pub = Path('pubspec.yaml')
if not pub.exists():
    raise SystemExit('pubspec.yaml not found. Run from the Flutter project root.')

version = os.environ.get('PATOGH_VERSION', '1.0.0+1').strip() or '1.0.0+1'
s = pub.read_text()
if re.search(r'^version:\s*', s, flags=re.M):
    s = re.sub(r'^version:.*$', f'version: {version}', s, flags=re.M)
else:
    s = s.replace('name: patogh', f'name: patogh\nversion: {version}', 1)

# Add brand/banner assets without depending on a YAML package.
asset_lines = [
    '    - assets/branding/patogh_logo.png',
    '    - assets/branding/app_icon_1024.png',
    '    - assets/branding/splash_public.jpg',
    '    - assets/banners/',
]
if not re.search(r'^flutter:\s*$', s, flags=re.M):
    s += '\nflutter:\n  uses-material-design: true\n'

if not re.search(r'^\s{2}assets:\s*$', s, flags=re.M):
    m = re.search(r'^flutter:\s*$', s, flags=re.M)
    insert = m.end()
    block = '\n  assets:\n' + '\n'.join(asset_lines) + '\n'
    s = s[:insert] + block + s[insert:]
else:
    lines = s.splitlines()
    idx = next(i for i,l in enumerate(lines) if re.match(r'^\s{2}assets:\s*$', l))
    existing = set(l.strip() for l in lines)
    for raw in reversed(asset_lines):
        if raw.strip() not in existing:
            lines.insert(idx + 1, raw)
    s = '\n'.join(lines) + ('\n' if not s.endswith('\n') else '')

pub.write_text(s)
print(f'Public release pubspec prepared: version={version}, brand assets registered')
