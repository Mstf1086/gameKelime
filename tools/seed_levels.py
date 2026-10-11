"""Firestore `levels` koleksiyonuna 30 seviyeyi REST API ile yazar.
Kimlik: firebase CLI login token'i kullanilir (service account gerekmez).
Kullanim: uv run python tools/seed_levels.py [--dry-run]
"""
import json
import os
import sys
import urllib.request
import urllib.error

PROJECT = 'gamekelime'


def _refresh_token() -> str:
    cfg = os.path.expanduser('~/.config/configstore/firebase-tools.json')
    d = json.load(open(cfg))
    return d['tokens']['refresh_token']


def _api_key() -> str:
    # Web app config'indeki gercek API key
    return 'AIzaSyCZRUjFLS_NpSmik0aPrNLOKfrm6BzIkBE'


def access_token() -> str:
    # firebase CLI'nin cache'ledigi OAuth access token (gecerliyse dogrudan kullan)
    import time
    cfg = os.path.expanduser('~/.config/configstore/firebase-tools.json')
    d = json.load(open(cfg))
    toks = d.get('tokens', {})
    if toks.get('access_token') and toks.get('expires_at', 0) > int(time.time() * 1000) + 60000:
        return toks['access_token']
    data = f'grant_type=refresh_token&refresh_token={_refresh_token()}'.encode()
    req = urllib.request.Request(
        f'https://securetoken.googleapis.com/v1/token?key={_api_key()}',
        data=data, method='POST',
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
    )
    return json.load(urllib.request.urlopen(req, timeout=20))['access_token']


def to_value(v):
    if isinstance(v, bool):
        return {'booleanValue': v}
    if isinstance(v, int):
        return {'integerValue': str(v)}
    if isinstance(v, float):
        return {'doubleValue': v}
    if isinstance(v, str):
        return {'stringValue': v}
    if isinstance(v, list):
        return {'arrayValue': {'values': [to_value(x) for x in v]}}
    if isinstance(v, dict):
        return {'mapValue': {'fields': {k: to_value(x) for k, x in v.items()}}}
    if v is None:
        return {'nullValue': None}
    raise ValueError(f'desteklenmeyen tip: {type(v)}')


def write_level(token: str, level: dict) -> None:
    doc_id = f"level_{level['level']:02d}"
    url = (f'https://firestore.googleapis.com/v1/projects/{PROJECT}'
           f'/databases/(default)/documents/levels/{doc_id}')
    body = json.dumps({'fields': {k: to_value(v) for k, v in level.items()}}).encode()
    req = urllib.request.Request(
        url, data=body, method='PATCH',
        headers={'Authorization': f'Bearer {token}',
                 'Content-Type': 'application/json'},
    )
    urllib.request.urlopen(req, timeout=20).read()


def main() -> None:
    dry = '--dry-run' in sys.argv
    levels = json.load(open('docs/sample_levels.json', encoding='utf-8'))
    print(f'{len(levels)} seviye okundu')
    if dry:
        print('dry-run: yazma yapilmadi')
        return
    token = access_token()
    ok, fail = 0, []
    for lv in levels:
        try:
            write_level(token, lv)
            ok += 1
            print(f"  level_{lv['level']:02d} OK")
        except urllib.error.HTTPError as e:
            body = e.read().decode(errors='replace')[:200]
            fail.append((lv['level'], e.code, body))
            print(f"  level {lv['level']} FAIL {e.code}: {body[:120]}")
    print(f'tamam: {ok} ok, {len(fail)} fail')
    if fail:
        sys.exit(1)


if __name__ == '__main__':
    main()
