/// Oyunun ayar ve kurallarını tutan tek kaynak dosya.
/// Puanlama formülü, joker sayısı ve zorluk basamakları burada tanımlanır.
class GameConfig {
  GameConfig._();

  // --- Seviye zorluk sınıflandırması ---
  static const int levelEasyUpTo = 10;       // 1-10: Kolay
  static const int levelMediumStart = 11;    // 11-20: Orta
  static const int levelMediumUpTo = 20;
  static const int levelHardStart = 21;      // 21+: Zor

  // --- Joker ayarları ---
  static const int maxJokersPerLevel = 3;
  static const int jokersToRemovePerUse = 3; // Joker 2: kaldırılacak max yanlış harf
  static const int joker2MaxWrong = 3;

  // --- Puanlama ---
  static const int basePointsEasy = 10;
  static const int basePointsMedium = 25;
  static const int basePointsHard = 50;

  static const int timeBonus = 20;       // seviye süresi dolmadan kazanılana ek puan
  static const int timePerSecond = 1;    // saniye başına düşen süre bonusu
  static const int jokerPenalty = 5;     // her joker kullanımı başına düşülen puan
  static const int jokerRemainingBonus = 10; // her kalan joker için bitiş bonusu

  // --- Level süresi ---
  static const int timeLimitMinutes = 3;
  static const Duration timeLimit = Duration(minutes: timeLimitMinutes);

  // --- Seviye ilerleme ---
  static const int minimumLevelToUnlock = 1;

  // --- Dil ---
  static const String gameLanguage = 'tr';

  // Zorluk bazlı puan alma
  static int basePointsForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return basePointsEasy;
      case Difficulty.medium:
        return basePointsMedium;
      case Difficulty.hard:
        return basePointsHard;
    }
  }

  static Difficulty difficultyForLevel(int level) {
    if (level <= levelEasyUpTo) return Difficulty.easy;
    if (level <= levelMediumUpTo) return Difficulty.medium;
    return Difficulty.hard;
  }

  static double difficultyMultiplier(int level) {
    return 1 + (level - 1) * 0.1;
  }

  /// Toplam puan hesaplama formülü:
  /// finalScore = (basePoints * difficultyMultiplier) + timeBonus
  ///              - (jokersUsed * jokerPenalty) + (remainingJokers * jokerRemainingBonus)
  static int calculateFinalScore({
    required int basePoints,
    required int level,
    required int jokersUsed,
    required int jokersRemaining,
    required int timeTakenSeconds,
  }) {
    final difficultyMult = difficultyMultiplier(level);
    final timeBonusPoints =
        timeLimit.inSeconds > timeTakenSeconds
            ? (timeLimit.inSeconds - timeTakenSeconds) * timePerSecond
            : 0;
    return (basePoints * difficultyMult).toInt() +
        timeBonusPoints +
        (jokersRemaining * jokerRemainingBonus) -
        (jokersUsed * jokerPenalty);
  }
}

enum Difficulty { easy, medium, hard }
