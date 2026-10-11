# gameKelime — Kelime Oyunu (Flutter)

Türkçe karakterleri destekleyen, Firebase Auth ve Firestore kullanan bir kelime tahmin oyunudur.
Web, Android ve iOS platformlarında çalışır.

## Özellikler

- Basitten zora doğru ilerleyen seviyeler (Kolay / Orta / Zor)
- Kategori ve tanıma dayalı sorular
- Ekrandaki Türkçe klavye ve harf kutuları
- Her levelde 3 joker hakkı (ipucu harfi, yanlış temizle, puan çarpanı)
- Puanlama sistemi (zorluk arttıkça puan artar)
- Firebase Auth ile kullanıcı girişi/kayıt
- Oyun kayıtlarının Firestore'da saklanması
- Profil ve puan sıralaması ekranları

## Gerekli Araçlar

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Bir **Firebase projesi** (console.firebase.google.com)

> **Not:** Bu cihazda Flutter kurulu değildir. Kod geliştirme burada yapılır;
> APK/Web build'i Flutter kurulu başka bir makinede alınır.

## Kurulum

1. Proje klasörünü bir makineye kopyalayın:
   ```bash
   cd gameKelime
   flutter pub get
   ```

2. Firebase projesini oluşturun ve proje kökünde yapılandırın:
   ```bash
   firebase login
   firebase init firestore
   firebase init hosting   # web için
   ```

3. `lib/firebase_options.dart` dosyasını Firebase Console'dan veya `flutterfire configure` ile doldurun
   (bu cihazda build alınamadığı için elle de oluşturulabilir).

4. Firestore'a şablon level verisini aktarın (`docs/sample_levels.json` — bkz. aşağıda).

5. Web için:
   ```bash
   flutter build web --release
   firebase hosting:deploy
   ```

6. Android için build makinesinde:
   ```bash
   flutter build apk --release          # test dağıtımı
   flutter build appbundle --release    # Google Play
   ```

## Build & Dağıtım (Build Yok / No Git Durumu İçin)

Bu proje Git kullanmaz ve build bu cihazda alınamaz. Önerilen dağıtım yolu:

1. **Kod paylaşımı:** Proje `.zip` olarak build makinesine aktarılır, `flutter pub get` yapılır.
2. **Web:** `firebase hosting:deploy` ile Firebase Hosting'e yüklenir; kullanıcılar web linkinden oynar.
3. **Mobil:** Build makinesinde alınan APK/AAB, **Firebase App Distribution** üzerinden dağıtılır:
   ```bash
   firebase appdistribution:upload build/app/outputs/flutter-apk/app-release.apk
   ```
   Dağıtım linki Firebase Console → App Distribution → Testers'dan oluşturulur.
4. Alternatif olarak Android APK doğrudan e-posta/cloud drive üzerinden paylaşılabilir.

## Dosya Yapısı

```
lib/
├── main.dart                 # uygulama başlangıcı
├── firebase_options.dart     # Firebase yapılandırması
├── core/                     # ortak katman
│   ├── constants/            # renk, metin, oyun ayarları
│   ├── errors/               # hata sınıfları
│   ├── network/              # ağ katmanı
│   ├── routes/               # sayfa yönlendirmeleri
│   ├── services/             # Firebase servisleri
│   ├── utils/                # yardımcı fonksiyonlar
│   └── widgets/              # ortak widget'lar
├── features/
│   ├── auth/                 # giriş/kayıt
│   ├── game/                 # oyun motoru
│   └── profile/              # profil ve puan tablosu
```

## Şablon Veri (Firestore)

`docs/sample_levels.json` içindeki veriler, Firestore `levels` koleksiyonuna aktarılmalıdır.
Aktarım için Firebase Console'da "Veri ekle" kullanılabilir veya
`tools/import_levels.dart` (build makinesinde) çalıştırılabilir.

## Lisans

Tüm hakları saklıdır.
