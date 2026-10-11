import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/firebase_errors.dart';
import '../../../core/services/firestore_service.dart';
import '../models/level_model.dart';

/// Level verilerinin Firestore yönetimi.
class LevelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tüm seviyeleri Firestore'dan getirir.
  Future<List<LevelModel>> getAllLevels() async {
    try {
      final snapshot =
          await _firestore.collection('levels').orderBy('level').get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return LevelModel.fromFirestore(data);
          })
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Belirli seviye id'sine göre level getirir.
  Future<LevelModel?> getLevelById(String id) async {
    try {
      final doc = await _firestore.collection('levels').doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = id;
      return LevelModel.fromFirestore(data);
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Aktif kullanıcıya göre ilerlemeyi döndürür.
  Future<int> getUnlockedLevel(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return GameConfig.minimumLevelToUnlock;
      final data = doc.data() as Map<String, dynamic>;
      return data['levelReached'] as int? ?? GameConfig.minimumLevelToUnlock;
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Seçili seviyeyi kilidi açılmış olarak işaretler.
  Future<void> unlockLevel(String userId, int level) async {
    try {
      final current = await getUnlockedLevel(userId);
      if (level > current) {
        await _firestore.collection('users').doc(userId).update({
          'levelReached': FieldValue.increment(level - current),
        });
      }
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Rastgele bir level seçer (oyun içi kullanım).
  Future<LevelModel?> getRandomLevel() async {
    try {
      final snapshot = await _firestore.collection('levels').get();
      if (snapshot.docs.isEmpty) return null;
      final randomIndex =
          List<int>.generate(snapshot.docs.length, (i) => i)..shuffle()[0];
      final doc = snapshot.docs[randomIndex];
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return LevelModel.fromFirestore(data);
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }
}
