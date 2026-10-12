"""GitHub Actions secretlarini API ile yazar (sealed box, pynacl gerekir).
Kullanim: GITHUB_TOKEN=... uv run --with pynacl python tools/set_secrets.py
"""
import base64
import json
import os
import pathlib
import urllib.request

REPO = 'Mstf1086/gameKelime'
TOKEN = os.environ['GITHUB_TOKEN']
P12 = pathlib.Path(__file__).resolve().parents[1] / 'android' / 'upload-keystore.p12'


def req(url, method='GET', data=None):
    r = urllib.request.Request(url, method=method)
    r.add_header('Accept', 'application/vnd.github+json')
    r.add_header('Authorization', f'Bearer {TOKEN}')
    r.add_header('User-Agent', 'gameKelime-secrets')
    if data is not None:
        r.add_header('Content-Type', 'application/json')
        data = json.dumps(data).encode()
    return json.load(urllib.request.urlopen(r, timeout=30, data=data))


def put_secret(name, value: str, pub):
    from nacl import public
    sealed = public.SealedBox(
        public.PublicKey(base64.b64decode(pub['key']))
    ).encrypt(value.encode())
    req(
        f'https://api.github.com/repos/{REPO}/actions/secrets/{name}',
        method='PUT',
        data={
            'encrypted_value': base64.b64encode(bytes(sealed)).decode(),
            'key_id': pub['key_id'],
        },
    )
    print(f'{name} OK')


def main():
    pub = req(f'https://api.github.com/repos/{REPO}/actions/secrets/public-key')
    put_secret('KEYSTORE_BASE64', base64.b64encode(P12.read_bytes()).decode(), pub)
    put_secret('KEYSTORE_PASSWORD', 'gameKelime2026!', pub)
    put_secret('KEYSTORE_ALIAS', 'upload', pub)


if __name__ == '__main__':
    main()
