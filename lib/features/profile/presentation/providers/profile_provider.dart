import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import '../../../../core/constants/strings.dart';
import '../../../../core/errors/firebase_errors.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/stats_model.dart';

/// Profil ve istatistikleri yöneten provider.
class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// İstatistikleri Firestore'dan yükler.
  Future<void> loadStats(AuthProvider authProvider) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      final user = authProvider.currentUser;
      if (user == null) throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Kullanıcı oturum açmamış.',
      );

      final userData = await _firestore.collection('users').doc(user.id).get();
      if (!userData.exists) {
        throw FirebaseErrors.unauthorized();
      }

      final gameRecordsData = await _firestore
          .collection('gameRecords')
          .where('userId', isEqualTo: user.id)
          .get()
          .then((s) => s.docs.map((d) {
                final m = d.data();
                m['id'] = d.id;
                return m;
              }).toList());

      _stats = ProfileStats.fromUserData(
        userData: userData.data()!,
        gameRecords: gameRecordsData,
        userId: user.id,
      );
    } on FirebaseErrors catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = Strings.errorUnknown;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kullanıcının oyun kayıtlarını döndürür (oyun geçmişi için).
  Future<List<Map<String, dynamic>>> getUserGameRecords(String? userId) async {
    if (userId == null) return [];
    try {
      final records = await _firestore
          .collection('gameRecords')
          .where('userId', isEqualTo: userId)
          .get()
          .then((s) => s.docs.map((d) {
                final m = d.data();
                m['id'] = d.id;
                return m;
              }).toList());
      final sorted = List<Map<String, dynamic>>.from(records)..sort((a, b) {
        final ta = a['createdAt'] is Timestamp ? (a['createdAt'] as Timestamp).toDate() : DateTime(1);
        final tb = b['createdAt'] is Timestamp ? (b['createdAt'] as Timestamp).toDate() : DateTime(1);
        return tb.compareTo(ta);
      });
      return sorted;
    } on FirebaseErrors catch (e) {
      throw e;
    } catch (e) {
      throw FirebaseErrors.authError('unknown');
    }
  }

  /// Tüm oyuncuların skorlarını döndürür (global sıralama için).
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final snapshot = await _firestore.collection('users').orderBy('totalScore', descending: true).limit(50).get();
      final List<Map<String, dynamic>> users = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        users.add({...data, 'id': doc.id});
      }
      return users;
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }
}
