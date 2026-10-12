"""Release keystore (PKCS12) üretir + Firebase'e eklenecek SHA-1'i basar.
Kullanim: uv run --with cryptography python tools/make_keystore.py
Cikti: android/upload-keystore.p12 (repo disinda tutulur, .gitignore'da)
"""
import base64
import datetime
import hashlib
import pathlib

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.x509.oid import NameOID

ALIAS = 'upload'
PASSWORD = b'gameKelime2026!'
OUT = pathlib.Path(__file__).resolve().parents[1] / 'android' / 'upload-keystore.p12'


def main() -> None:
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    name = x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, 'gameKelime upload key'),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, 'gameKelime'),
    ])
    now = datetime.datetime.now(datetime.timezone.utc)
    cert = (
        x509.CertificateBuilder()
        .subject_name(name)
        .issuer_name(name)
        .public_key(key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(now - datetime.timedelta(days=1))
        .not_valid_after(now.replace(year=now.year + 30))
        .add_extension(x509.BasicConstraints(ca=True, path_length=None), critical=True)
        .sign(key, hashes.SHA256())
    )
    OUT.parent.mkdir(parents=True, exist_ok=True)
    p12 = pkcs12.serialize_key_and_certificates(
        name=ALIAS.encode(),
        key=key,
        cert=cert,
        cas=None,
        encryption_algorithm=serialization.BestAvailableEncryption(PASSWORD),
    )
    OUT.write_bytes(p12)

    sha1 = hashlib.sha1(cert.tbs_certificate_bytes).hexdigest().upper()
    sha1_fmt = ':'.join(sha1[i:i + 2] for i in range(0, len(sha1), 2))
    print(f'keystore: {OUT}')
    print(f'alias: {ALIAS}')
    print(f'password: {PASSWORD.decode()}')
    print(f'sha1: {sha1_fmt}')
    print(f'base64 ({len(p12)} bayt):')
    print(base64.b64encode(p12).decode())


if __name__ == '__main__':
    main()
