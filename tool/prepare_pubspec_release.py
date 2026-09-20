from pathlib import Path
import re
p=Path('pubspec.yaml')
if not p.exists(): raise SystemExit('pubspec.yaml not found')
s=p.read_text()
if re.search(r'^version:',s,flags=re.M): s=re.sub(r'^version:.*$','version: 1.0.0+1',s,flags=re.M)
else: s=s.replace('name: patogh','name: patogh\nversion: 1.0.0+1')
p.write_text(s)
print('pubspec version set to 1.0.0+1')
