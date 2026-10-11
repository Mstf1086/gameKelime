import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/game_config.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/errors/firebase_errors.dart';
import '../../../../core/services/timer_service.dart';
import '../../../../core/utils/game_utils.dart';
import '../../data/models/level_model.dart';

/// Oyun oturumunun state'ini yöneten provider.
class GameProvider extends ChangeNotifier {
  final TimerService _timerService;

  LevelModel? _level;
  final Set<String> _guessedLetters = {};
  final Set<String> _wrongLetters = {};
  final Set<String> _usedJokers = {};
  final Set<String> _activeKeys = {};
  int _lives = 5;
  int _score = 0;
  bool _isGameOver = false;
  bool _isWin = false;
  bool _isLoading = false;
  String? _error;

  GameProvider({TimerService? timerService})
      : _timerService = timerService ?? TimerService();

  LevelModel? get level => _level;
  Set<String> get guessedLetters => Set.unmodifiable(_guessedLetters);
  Set<String> get wrongLetters => Set.unmodifiable(_wrongLetters);
  Set<String> get usedJokers => Set.unmodifiable(_usedJokers);
  Set<String> get activeKeys => Set.unmodifiable(_activeKeys);
  int get lives => _lives;
  int get score => _score;
  Duration get remainingTime => _timerService.remaining;
  bool get isGameOver => _isGameOver;
  bool get isWin => _isWin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWon => _isWin;
  bool get hasLost => _isGameOver && !_isWin;

  bool get hasJoker1 => !_usedJokers.contains('joker1');
  bool get hasJoker2 => !_usedJokers.contains('joker2');
  bool get hasJoker3 => !_usedJokers.contains('joker3');

  /// Yeni level başlatır.
  Future<void> startLevel(LevelModel level) async {
    _level = level;
    _guessedLetters.clear();
    _wrongLetters.clear();
    _usedJokers.clear();
    _activeKeys.clear();
    _activeKeys.addAll(GameUtils.getDefaultActiveKeys());
    _lives = 5;
    _score = 0;
    _isGameOver = false;
    _isWin = false;
    _error = null;

    // Kelime harflerini otomatik olarak açık say
    _score += _level!.basePoints;

    _timerService.stop();
    _timerService.setLimit(GameConfig.timeLimit);
    _timerService.start();
    notifyListeners();
  }

  /// Harf tahmini yapar.
  void guessLetter(String letter) {
    if (_level == null || _isGameOver) return;
    final upper = letter.toUpperCase();
    if (_guessedLetters.contains(upper)) return;

    _guessedLetters.add(upper);
    _activeKeys.add(upper);

    final answer = _level!.answer.toUpperCase();
    if (answer.contains(upper)) {
      _checkWinCondition();
    } else {
      _wrongLetters.add(upper);
      _lives--;
      if (_lives <= 0) {
        _endGame(win: false);
      }
    }
    notifyListeners();
  }

  /// Joker 1: Rastgele 1 doğru harf aç.
  void useJoker1() {
    if (_level == null || _isGameOver || !hasJoker1) return;
    final answer = _level!.answer.toUpperCase();
    final hidden = answer.split('').where((l) => !_guessedLetters.contains(l)).toList();
    if (hidden.isEmpty) return;

    hidden.shuffle();
    final revealed = hidden.first;
    _guessedLetters.add(revealed);
    _activeKeys.add(revealed);
    _usedJokers.add('joker1');
    _checkWinCondition();
    notifyListeners();
  }

  /// Joker 2: En fazla 3 yanlış harfi kaldır.
  void useJoker2() {
    if (_level == null || _isGameOver || !hasJoker2) return;
    final answer = _level!.answer.toUpperCase();
    final wrongs = _wrongLetters.toList()..shuffle();
    final removeCount = min(GameConfig.joker2MaxWrong, wrongs.length);
    for (var i = 0; i < removeCount; i++) {
      final letter = wrongs[i];
      _wrongLetters.remove(letter);
      _activeKeys.remove(letter);
      _guessedLetters.remove(letter);
    }
    _usedJokers.add('joker2');
    notifyListeners();
  }

  /// Joker 3: O level puanını 2'ye çarp.
  void useJoker3() {
    if (_level == null || _isGameOver || !hasJoker3) return;
    _score *= 2;
    _usedJokers.add('joker3');
    notifyListeners();
  }

  void _checkWinCondition() {
    final answer = _level!.answer.toUpperCase();
    final allRevealed = answer
        .split('')
        .every((letter) => _guessedLetters.contains(letter));
    if (allRevealed) {
      _endGame(win: true);
    }
  }

  void _endGame({required bool win}) {
    _isGameOver = true;
    _isWin = win;
    _timerService.stop();
    if (win) {
      _calculateFinalScore();
    }
    notifyListeners();
  }

  void _calculateFinalScore() {
    if (_level == null) return;
    final secondsElapsed =
        GameConfig.timeLimit.inSeconds - _timerService.remaining.inSeconds;
    _score = GameConfig.calculateFinalScore(
      basePoints: _level!.basePoints,
      level: _level!.level,
      jokersUsed: _usedJokers.length,
      jokersRemaining: GameConfig.maxJokersPerLevel - _usedJokers.length,
      timeTakenSeconds: secondsElapsed,
    );
  }

  /// Oyun sonucunu Firestore'a kaydeder.
  Future<void> saveGameRecord({required String userId}) async {
    if (_level == null) return;
    try {
      final secondsElapsed =
          GameConfig.timeLimit.inWholeSeconds - _timerService.remaining.inWholeSeconds;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('gameRecords')
          .add({
        'level': _level!.level,
        'word': _level!.answer,
        'score': _score,
        'timeTaken': secondsElapsed,
        'jokersUsed': _usedJokers.toList(),
        'result': _isWin ? 'win' : 'lose',
        'createdAt': Timestamp.now(),
      });

      // Kullanıcı istatistiklerini güncelle
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'gamesPlayed': FieldValue.increment(1),
        if (_isWin) 'gamesWon': FieldValue.increment(1),
        'totalScore': FieldValue.increment(_score),
      });
    } on FirebaseException catch (e) {
      _error = FirebaseErrors.firestoreError(e).message;
    } catch (e) {
      _error = Strings.errorUnknown;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timerService.stop();
    _timerService.dispose();
    super.dispose();
  }
}
