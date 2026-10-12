/// Oyun ile ilgili yardımcı fonksiyonlar (klavye düzeni, harf işlemleri vb.).
class GameUtils {
  GameUtils._();

  /// Türkçe Q klavye satırları (fiziksel Türkçe Q düzeni).
  /// Sesli harfler her zaman aktiftir, sessiz harfler oyun
  /// başlangıcında pasiftir.
  static const List<List<String>> _turkishQRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'],
  ];

  /// Türkçe Q klavyedeki tüm harfler (benzersiz, satır sırasıyla).
  static const List<String> _turkishQKeyboard = [
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü',
    'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ',
    'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç',
  ];

  /// Varsayılan aktif harfler (sesli harfler + yaygın sessizler).
  static const Set<String> _defaultActiveKeys = {
    'A', 'E', 'I', 'İ', 'O', 'Ö', 'U', 'Ü',
    'M', 'N', 'R', 'S', 'T',
  };

  /// Klavyedeki tüm tuşları döndürür.
  static List<String> getFullKeyboard() => List.unmodifiable(_turkishQKeyboard);

  /// Başlangıçta aktif olan tuşları döndürür.
  static Set<String> getDefaultActiveKeys() =>
      Set.unmodifiable(_defaultActiveKeys);

  /// Klavye satırlarını döndürür (Türkçe Q fiziksel düzeni).
  static List<List<String>> getKeyboardRows() {
    return List.unmodifiable(_turkishQRows);
  }

  /// Kelimenin harf dağılımını hesaplar: harf -> tekrar sayısı.
  static Map<String, int> getLetterFrequency(String word) {
    final Map<String, int> freq = {};
    for (final letter in word.toUpperCase().split('')) {
      freq[letter] = (freq[letter] ?? 0) + 1;
    }
    return Map.unmodifiable(freq);
  }

  /// Bir harfin klavyede olup olmadığını kontrol eder.
  static bool isKeyInKeyboard(String key) {
    return _turkishQKeyboard.contains(key.toUpperCase());
  }

  /// Yanlış tahmin sayısı (kelime içinde olmayan harfler).
  static int countWrongLetters(String answer, String guessed) {
    final answerUpper = answer.toUpperCase();
    final guessedUpper = guessed.toUpperCase();
    int wrong = 0;
    for (final letter in guessedUpper.split('')) {
      if (!answerUpper.contains(letter)) {
        wrong++;
      }
    }
    return wrong;
  }

  /// Girilmiş harflerin tekrarını önler.
  static String filterUniqueGuessed(String guessed) {
    final seen = <String>{};
    final buffer = StringBuffer();
    for (final letter in guessed.split('')) {
      if (seen.add(letter.toUpperCase())) {
        buffer.write(letter);
      }
    }
    return buffer.toString();
  }

  /// Bir harf kutusunun içeriğini hazırlar (açık/ kapalı).
  static String renderLetterBox(String answer, String guessed, int index) {
    final letter = answer[index].toUpperCase();
    if (guessed.contains(letter)) {
      return letter;
    }
    return '_';
  }

  /// Tüm harf kutularını birlikte hazırlar: ['_', 'A', '_', 'L'] gibi.
  static List<String> renderLetterBoxes(String answer, String guessed) {
    return answer
        .split('')
        .map((letter) => guessed.contains(letter) ? letter : '_')
        .toList();
  }

  /// Geçerli kelime kontrolü (boşluk, rakam içermemeli, Türkçe karakter izinli).
  static bool isValidWord(String word) {
    final normalized = word.trim().toUpperCase();
    return normalized.isNotEmpty &&
        RegExp(r'^[A-ZĞÜŞİÖÇ]+$', caseSensitive: false).hasMatch(normalized);
  }

  /// Sistem klavyesinden gelen harfi cevaba göre normalize eder.
  /// Türkçe olmayan klavyede g→ğ, c→ç, s→ş, u→ü, o→ö, i→ı/İ yerine
  /// yazıldığında kabul edilir ve cevaptaki doğru (Türkçe) harf döndürülür.
  /// Harf cevapta hiç yoksa yazılan harf aynen döndürülür (yanlış tahmin).
  /// Harf olmayan girdiler (boşluk, rakam, noktalama) için null döner.
  static String? normalizeLetterForAnswer(String raw, String answer) {
    final up = raw.toUpperCase();
    if (up.length != 1 || !RegExp(r'^[A-ZÇĞİÖŞÜ]$').hasMatch(up)) {
      return null;
    }
    final ans = answer.toUpperCase();
    if (ans.contains(up)) return up;
    const toTurkish = {'G': 'Ğ', 'C': 'Ç', 'S': 'Ş', 'I': 'İ', 'U': 'Ü', 'O': 'Ö'};
    final turkish = toTurkish[up];
    if (turkish != null && ans.contains(turkish)) return turkish;
    const toAscii = {'Ğ': 'G', 'Ç': 'C', 'Ş': 'S', 'İ': 'I', 'Ü': 'U', 'Ö': 'O'};
    final ascii = toAscii[up];
    if (ascii != null && ans.contains(ascii)) return ascii;
    return up;
  }
}
