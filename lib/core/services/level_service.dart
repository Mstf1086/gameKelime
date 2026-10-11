import 'package:flutter/foundation.dart';
import '../constants/game_config.dart';
import '../constants/strings.dart';
import '../errors/firebase_errors.dart';
import '../utils/game_utils.dart';
import 'firestore_service.dart';
import '../../features/game/data/models/level_model.dart';

/// Level verisini Firestore'dan yöneten servis.
class LevelService extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<LevelModel> _levels = [];
  List<LevelModel> _availableLevels = [];
  int _unlockedLevel = 1;
  int _currentLevelIndex = 0;
  bool _isLoading = false;
  String? _error;

  List<LevelModel> get levels => List.unmodifiable(_levels);
  List<LevelModel> get availableLevels => List.unmodifiable(_availableLevels);
  int get unlockedLevel => _unlockedLevel;
  int get currentLevelIndex => _currentLevelIndex;
  LevelModel? get currentLevel {
    if (_currentLevelIndex >= 0 &&
        _currentLevelIndex < _availableLevels.length) {
      return _availableLevels[_currentLevelIndex];
    }
    return null;
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLevelUnlocked(int level) => level <= _unlockedLevel;

  Future<void> loadLevels() async {
    try {
      _isLoading = true;
      _error = null;
      _levels = (await _firestore.collectionCollection('levels'))
          .map((doc) => LevelModel.fromFirestore(doc))
          .toList();
      _sortAndAssignLevels();
    } on FirebaseErrors catch (e) {
      _error = e.message;
    } catch (e) {
      _error = Strings.errorUnknown;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sortAndAssignLevels() {
    _levels.sort((a, b) => a.level.compareTo(b.level));
    // Level sırasına göre zorluk hesaplanır
    for (final level in _levels) {
      level.difficulty = GameConfig.difficultyForLevel(level.level);
    }
    _availableLevels = List.from(_levels);
  }

  /// Seçili seviyeyi başlatır (oyun için hazırlık).
  Future<void> startLevel(int level) async {
    try {
      assert(_availableLevels.isNotEmpty, Strings.errorLevelNotFound);
      final target = _availableLevels.firstWhere(
        (l) => l.level == level,
        orElse: () => throw FirebaseErrors.levelNotFound(level),
      );
      _currentLevelIndex = _availableLevels.indexOf(target);
      notifyListeners();
    } on FirebaseErrors catch (e) {
      _error = e.message;
    } catch (e) {
      _error = Strings.errorLevelNotFound;
    }
  }

  /// Seviye atlandıktan sonra sonraki seviyeyi başlatır.
  void nextLevel() {
    _currentLevelIndex++;
    if (_currentLevelIndex >= _availableLevels.length) {
      _currentLevelIndex = 0;
    }
    notifyListeners();
  }

  /// Başarılı tamamlanan level için: kilidi aç, seviye sayısını güncelle.
  void unlockLevel(int level) {
    if (level > _unlockedLevel) {
      _unlockedLevel = level;
      notifyListeners();
    }
  }

  /// Rastgele bir level döndürür (deneme modu için).
  LevelModel? getRandomLevel() {
    if (_availableLevels.isEmpty) return null;
    final random = List<int>.generate(
      _availableLevels.length,
      (i) => i,
    )..shuffle();
    return _availableLevels[random[0]];
  }

  /// Belirli bir zorluktaki level listesini filtreler.
  List<LevelModel> levelsByDifficulty(Difficulty difficulty) {
    return _availableLevels
        .where((l) => l.difficulty == difficulty)
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
