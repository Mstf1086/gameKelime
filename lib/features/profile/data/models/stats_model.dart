/// Kullanıcı istatistik modelidir (gameRecords verisinden türetilir).
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileStats {
  final String userId;
  final String displayName;
  final String email;
  final int totalScore;
  final int levelReached;
  final int gamesWon;
  final int gamesPlayed;
  final int streak;
  final int bestScore;
  final DateTime? lastPlayed;

  ProfileStats({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.totalScore,
    required this.levelReached,
    required this.gamesWon,
    required this.gamesPlayed,
    required this.streak,
    required this.bestScore,
    this.lastPlayed,
  });

  /// Firestore kullanıcı belgesinden ve oyun kayıtlarından istatistikleri oluşturur.
  factory ProfileStats.fromUserData({
    required Map<String, dynamic> userData,
    required List<Map<String, dynamic>> gameRecords,
    String? userId,
  }) {
    final totalScore = userData['totalScore'] as int? ?? 0;
    final levelReached = userData['levelReached'] as int? ?? 1;
    final gamesWon = userData['gamesWon'] as int? ?? 0;
    final gamesPlayed = userData['gamesPlayed'] as int? ?? 0;

    // Son oynama tarihi
    DateTime? lastPlayed;
    DateTime? bestScoreDate;
    int bestScore = 0;
    for (final record in gameRecords) {
      final recordScore = record['score'] as int? ?? 0;
      if (recordScore > bestScore) {
        bestScore = recordScore;
        final ts = record['createdAt'];
        if (ts is Timestamp) {
          bestScoreDate = ts.toDate();
        }
      }
      final ts = record['createdAt'];
      if (ts is Timestamp) {
        final date = ts.toDate();
        if (lastPlayed == null || date.isAfter(lastPlayed!)) {
          lastPlayed = date;
        }
      }
    }

    // Dizilim hesabı (son 3 oyun kazanma sayısı)
    int streak = 0;
    final sorted = List<Map<String, dynamic>>.from(gameRecords)..sort((a, b) {
      final ta = a['createdAt'] is Timestamp ? (a['createdAt'] as Timestamp).toDate() : DateTime(1);
      final tb = b['createdAt'] is Timestamp ? (b['createdAt'] as Timestamp).toDate() : DateTime(1);
      return tb.compareTo(ta);
    });
    for (final record in sorted) {
      if (record['result'] == 'win') {
        streak++;
      } else {
        break;
      }
    }

    return ProfileStats(
      userId: userId ?? userData['id'] as String,
      displayName: userData['displayName'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      totalScore: totalScore,
      levelReached: levelReached,
      gamesWon: gamesWon,
      gamesPlayed: gamesPlayed,
      streak: streak,
      bestScore: bestScore,
      lastPlayed: lastPlayed ?? bestScoreDate,
    );
  }
}
