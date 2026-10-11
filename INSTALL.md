# gameKelime — Kurulum Kılavuzu

Türkçe karakterleri destekleyen, Firebase Auth ve Firestore kullanan bir kelime tahmin oyunudur. Web, Android ve iOS platformlarında çalışır.

> **Not:** Oyunun geliştirme ortamı bu çalıştayda oluşturulmuştur; ancak bu cihazda Flutter kurulu değildir. Kod buradan yönetilir, APK/Web **build'leri Flutter kurulu başka bir makinede** alınır.

---

## 1. Gerekli Araçlar

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (build almak için)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Git kullanılmadığı için dosya aktarımı **`.zip`** veya benzeri bir yöntemle yapılır

## 2. Proje Kurulumu (Build Makinesinde)

1. Proje klasörünü (bu çalıştayda `/root/gameKelime`) build makinesine kopyalayın:
   ```bash
   cd gameKelime
   ```

2. Bağımlılıkları indirin:
   ```bash
   flutter pub get
   ```

3. (Opsiyonel) Dart kod kalitesini kontrol edin — Flutter kuruluyken derlenip analiz edilebilir:
   ```bash
   flutter analyze
   ```

## 3. Firebase Projesi Kurulumu

1. [Firebase Console](https://console.firebase.google.com/) → **Project creation** ile yeni bir proje oluşturun (örnek: `gameKelime`).

2. **Authentication:**
   - Sol menüden **Build → Authentication** → **Get started**
   - Sağlayıcıları açın: **Email/Password**, **Google**, **Anonymous**

3. **Firestore Database:**
   - **Build → Firestore Database** → **Create database**
   - Başlangıçta **Test mode** seçin (daha sonra güvenli kurallara geçilecek — bkz. Bölüm 5)

4. **Web uygulaması ekleyin:**
   - Proje genel ayarlarına (dişli çark) → **General** → **Your apps** bölümünde **</>** (Web) ikonuna tıklayın
   - Uygulama adını `gameKelime Web` olarak girin ve kaydedin
   - Siz verilen `firebaseConfig` bloğunu aşağıdaki `lib/firebase_options.dart` dosyasına yapıştırın
     - Web uygulaması için **Authorized domains** listesine `localhost` (test) ve sonra prod domain'i ekleyin

5. **Android uygulaması ekleyin** (mobil build almak için):
   - Paket adı: `com.example.gamekelime` (veya istediğiniz bir package name)
   - `google-services.json`'ı indirip Android `app/` klasörüne yerleştirin

6. **iOS uygulaması ekleyin** (iOS build almak için):
   - Bundle ID: `com.example.gameKelime`
   - `GoogleService-Info.plist`'i iOS `Runner/` klasörüne yerleştirin

### `lib/firebase_options.dart` Yapılandırması

`lib/firebase_options.dart` dosyasındaki `web` (ve `android`/`ios`) FirebaseOptions sabitlerini Firebase Console'dan aldığınız config ile doldurun. Web uygulaması için **Authorized domains** listesine `localhost` ve prod domain'i eklemeyi unutmayın.

## 4. Firestore Şablon Verisinin Aktarılması

Oyunun seviyelerini `docs/sample_levels.json` içinde bulabilirsiniz. Bu veriyi Firestore `levels` koleksiyonuna aktarın.

**Firebase Console üzerinden:**
1. **Firestore Database** → **Start collection**
2. Collection ID: `levels`, Document ID: otomatik (veya seviye numarası)
3. `docs/sample_levels.json` dosyasındaki her satırı bir belgeye dönüştürün
4. Her belge için aşağıdaki alanları yazın:
   - `level` (numara): 1, 2, 3 ...
   - `category` (string): "DOĞALAR", "HAYVANLAR" ...
   - `question` (string): soru metni
   - `answer` (string): cevap kelimesi
   - `hint` (string): ipucu
   - `basePoints` (numara): 10, 25 veya 50
   - `answerLength` (numara): cevap harf sayısı

## 5. Firestore Güvenlik Kuralları

Test modu açık olduğu sürece herkes okuma/yazma yapabilir. Canlıya almadan önce aşağıdaki kuralları ekleyin:

**Firestore Rules:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /levels/{level} {
      allow read: if true;
      allow write: if false;
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
    match /users/{userId}/gameRecords/{record} {
      allow read, create: if request.auth != null && request.auth.uid == userId;
      allow delete: if false;
    }
  }
}
```

## 6. Build Alma (Build Makinesinde)

**Web:**
```bash
flutter build web --release
# Çıktı: build/web/ klasöründe
```

**Android APK (test dağıtımı):**
```bash
flutter build apk --release
# Çıktı: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (Google Play):**
```bash
flutter build appbundle --release
# Çıktı: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
flutter build ios --release
```

## 7. Dağıtım

### Web Dağıtımı (Firebase Hosting)

```bash
firebase init hosting     # mevcut Firebase projesini seçin
# build/web/ klasörünü hosting public dizini olarak ayarlayın
firebase hosting:deploy
```
Build makinesinde build aldıktan sonra `firebase hosting:deploy` ile web'i yayına alın.

### Mobil Dağıtımı (Firebase App Distribution)

```bash
firebase appdistribution:upload build/app/outputs/flutter-apk/app-release.apk
```
Firebase Console → **App Distribution** → **Testers** sayfasından tester ekleyip dağıtım linkini paylaşın.

**Alternatif:** APK dosyasını doğrudan e-posta / cloud drive üzerinden dağıtabilirsiniz.

## 8. Kullanıcı Akışı

1. `WelcomePage` → **Giriş Yap** veya **Kayıt Ol**
2. Giriş/kayıt sonrası `HomePage` (Oyna, Kurallar, Puan Sıralaması, Oyun Geçmişi)
3. `LevelSelectPage` → kilitli olmayan seviyeye tıkla
4. `GamePage` → klavyeden harf gir, jokerleri kullan, seviyeyi tamamla
5. `GameResultPage` → sonuç ekranı
6. `ProfilePage` / `LeaderboardPage` / `GameHistoryPage`

## Lisans

Tüm hakları saklıdır.
