"""CI adimi: android/app/build.gradle'a release keystore signing ekler.
Ortam degiskenleri: KEYSTORE_FILE, KEYSTORE_STORE_PASSWORD,
KEYSTORE_KEY_ALIAS, KEYSTORE_KEY_PASSWORD (gradle.properties'a yazilir).
"""
import os
import re

p = 'android/app/build.gradle'
s = open(p).read()

if 'signingConfigs.release' in s:
    print('zaten yamali')
    raise SystemExit(0)

if not os.environ.get('KEYSTORE_FILE'):
    print('KEYSTORE_FILE yok, signing yamasi atlandi')
    raise SystemExit(0)

# 1) release buildType'inda debug signing -> release signing
s2, n = re.subn(
    r"(release\s*\{[^}]*?)signingConfig\s+signingConfigs\.debug",
    r"\1signingConfig signingConfigs.release",
    s,
    count=1,
    flags=re.S,
)
if n == 0:
    print('UYARI: release signingConfig deseni bulunamadi, degisiklik yok')
    raise SystemExit(0)

# 2) android.signingConfigs release blogu (gradle.properties keyleri ile)
s2 += '''
android.signingConfigs {
    release {
        storeFile file(KEYSTORE_FILE)
        storePassword KEYSTORE_STORE_PASSWORD
        keyAlias KEYSTORE_KEY_ALIAS
        keyPassword KEYSTORE_KEY_PASSWORD
    }
}
'''

open(p, 'w').write(s2)
print('patch ok: release signing aktif')
