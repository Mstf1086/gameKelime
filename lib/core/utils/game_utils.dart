/// Oyun ile ilgili yardımcı fonksiyonlar (klavye düzeni, harf işlemleri vb.).
class GameUtils {
  GameUtils._();

  /// Türkçe Q klavye düzeni. Sesli harfler her zaman aktiftir,
  /// sessiz harfler oyun başlangıcında pasiftir.
  static const List<String> _turkishQKeyboard = [
    'Q', 'Ğ', 'Ü', 'Ş', 'I', 'Ö', 'Ç', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'V',
    'Y', 'Z',
  ];

  /// Varsayılan aktif harfler (sesli harfler + yaygın sessizler).
  static const Set<String> _defaultActiveKeys = {
    'A', 'E', 'I', 'O', 'Ö', 'U', 'Ü',
    'M', 'N', 'R', 'S', 'T',
  };

  /// Klavyedeki tüm tuşları döndürür.
  static List<String> getFullKeyboard() => List.unmodifiable(_turkishQKeyboard);

  /// Başlangıçta aktif olan tuşları döndürür.
  static Set<String> getDefaultActiveKeys() =>
      Set.unmodifiable(_defaultActiveKeys);

  /// Klavye satırını hesaplar (yaklaşık 10 tuşlu satırlar).
  static List<List<String>> getKeyboardRows() {
    final List<List<String>> rows = [];
    const int charsPerRow = 10;
    for (var i = 0; i < _turkishQKeyboard.length; i += charsPerRow) {
      rows.add(_turkishQKeyboard.sublist(
        i,
        i + charsPerRow > _turkishQKeyboard.length
            ? _turkishQKeyboard.length
            : i + charsPerRow,
      ));
    }
    return List.unmodifiable(rows);
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
}
