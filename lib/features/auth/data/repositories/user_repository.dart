import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/firebase_errors.dart';
import '../../../core/services/firestore_service.dart';
import '../models/user_model.dart';

/// Kullanıcı profili ve istatistiklerinin Firestore yönetimi.
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  String? get userId => _userId;

  /// Aktif kullanıcıya göre userId'yi ayarlar.
  void setUserId(String uid) {
    _userId = uid;
  }

  /// Kullanıcı kaydı oluşturur (Firestore'da user belgesi).
  Future<void> createUserRecord(UserModel user) async {
    try {
      assert(_userId != null, 'Kullanıcı tanımlı değil');
      await _firestore.collection('users').doc(_userId).set(user.toFirestore());
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Kullanıcı verisini Firestore'dan getirir.
  Future<UserModel?> getUserRecord(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = uid;
      return UserModel.fromFirestore(data);
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Aktif kullanıcının verisini getirir.
  Future<UserModel?> getCurrentUserRecord() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return getUserRecord(user.uid);
  }

  /// Kullanıcı verisini günceller.
  Future<void> updateUserRecord(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Kullanıcı istatistiklerini günceller (toplam skor, kazanılan oyun vb.).
  Future<void> updateStats({
    required String uid,
    int? totalScore,
    int? levelReached,
    int? gamesWon,
    int? gamesPlayed,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (totalScore != null) updates['totalScore'] = FieldValue.increment(totalScore);
      if (levelReached != null) updates['levelReached'] = FieldValue.increment(levelReached);
      if (gamesWon != null) updates['gamesWon'] = FieldValue.increment(gamesWon);
      if (gamesPlayed != null) updates['gamesPlayed'] = FieldValue.increment(gamesPlayed);
      await _firestore.collection('users').doc(uid).update(updates);
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Kullanıcıyı siler (Firestore kaydı dahil).
  Future<void> deleteUserRecord(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }
}
