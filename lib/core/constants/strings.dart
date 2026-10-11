class Strings {
  Strings._();

  // Uygulama başlığı
  static const String appTitle = 'Kelime Oyunu';
  static const String appTitleShort = 'Kelime';

  // Sayfa başlıkları
  static const String welcomeTitle = 'Kelime Oyunu';
  static const String signInTitle = 'Giriş Yap';
  static const String signUpTitle = 'Kayıt Ol';
  static const String homeTitle = 'Oyna';
  static const String rulesTitle = 'Kurallar';
  static const String profileTitle = 'Profil';
  static const String leaderboardTitle = 'Puan Sıralaması';
  static const String historyTitle = 'Oyun Geçmişi';
  static const String levelSelectTitle = 'Seviye Seç';

  // Butonlar
  static const String continueButton = 'Devam Et';
  static const String startButton = 'Başla';
  static const String playButton = 'Oyna';
  static const String signUpButton = 'Kayıt Ol';
  static const String signInButton = 'Giriş Yap';
  static const String logOutButton = 'Çıkış Yap';
  static const String yesButton = 'Evet';
  static const String noButton = 'Hayır';
  static const String retryButton = 'Tekrar Dene';
  static const String homeButton = 'Ana Menü';

  // Form alanları
  static const String emailLabel = 'E-posta';
  static const String passwordLabel = 'Şifre';
  static const String confirmPasswordLabel = 'Şifre Tekrarı';
  static const String displayNameLabel = 'Adınız';

  // Hata mesajları
  static const String errorUnknown = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNetwork = 'İnternet bağlantısı kontrol edin.';
  static const String errorAuthEmailEmpty = 'E-posta adresi boş olamaz.';
  static const String errorAuthPasswordEmpty = 'Şifre boş olamaz.';
  static const String errorAuthWeakPassword = 'Şifre en az 6 karakter olmalıdır.';
  static const String errorAuthEmailInvalid = 'Geçerli bir e-posta adresi girin.';
  static const String errorAuthPasswordMismatch = 'Şifreler eşleşmiyor.';
  static const String errorAuthAlreadyExists = 'Bu e-posta zaten kayıtlı.';
  static const String errorAuthWrongPassword = 'E-posta veya şifre hatalı.';
  static const String errorAuthUserNotFound = 'Kullanıcı bulunamadı.';
  static const String errorFirestoreUninitialized = 'Firestore henüz başlatılmadı.';
  static const String errorLevelNotFound = 'Seviye bulunamadı.';

  // Oyun metinleri
  static const String categoryLabel = 'Kategori';
  static const String questionLabel = 'Soru';
  static const String scoreLabel = 'Skor';
  static const String levelLabel = 'Seviye';
  static const String livesLabel = 'Can';
  static const String timeLabel = 'Süre';
  static const String joker1Label = 'İpucu Harfi';
  static const String joker2Label = 'Yanlış Temizle';
  static const String joker3Label = 'Puan Çarpanı';
  static const String jokerCount = 'Joker';
  static const String totalScoreLabel = 'Toplam Skor';
  static const String levelsUnlockedLabel = 'Açılan Seviye';
  static const String gamesPlayedLabel = 'Oynanan Oyun';
  static const String gamesWonLabel = 'Kazanılan Oyun';
  static const String streakLabel = 'Dizilim';
  static const String bestScoreLabel = 'En İyi Skor';

  // Game over ekranı
  static const String gameWonTitle = 'Tebrikler!';
  static const String gameLostTitle = 'Oyun Bitti';
  static const String gameResultMessage = 'Kelime: ';

  // Profil
  static const String editProfileButton = 'Profili Düzenle';
  static const String changePasswordButton = 'Şifre Değiştir';
  static const String deleteAccountButton = 'Hesabı Sil';
  static const String confirmDeleteAccount =
      'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  // Sponsor/Kapak
  static const String welcomeSubtitle =
      'Kategorilere ve tanımlara göre kelime tahmin edin.\n'
      'Kolaydan zora doğru ilerleyin ve en yüksek skoru yapın!';
  static const String haveAccount = 'Hesabınız var mı?';
  static const String noAccount = 'Hesabınız yok mu?';
  static const String signInHere = 'buradan giriş yapın';
  static const String signUpHere = 'buradan kayıt olun';

  // Yükleniyor
  static const String loading = 'Yükleniyor...';

  // Kurallar başlıkları
  static const String rulesHeadingOne = 'Genel';
  static const String rulesHeadingTwo = 'Seviye Sistemi';
  static const String rulesHeadingThree = 'Oynanış';
  static const String rulesHeadingFour = 'Joker Hakları';
  static const String rulesHeadingFive = 'Puanlama';
  static const String rulesHeadingSix = 'Kayıtlar';

  // Joker açıklama metinleri
  static const String joker1Desc = 'Rastgele 1 doğru harfi açar';
  static const String joker2Desc = 'En fazla 3 yanlış harfi kaldırır';
  static const String joker3Desc = 'O leveldeki puanı 2\'ye çarpar';
}
