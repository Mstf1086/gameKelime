import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/errors/firebase_errors.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Giriş/kayıt akışını yöneten state provider.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  String? _loadedProfileUid;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authRepository.authStateChanges.listen((user) {
      if (user == null) {
        _currentUser = null;
        _loadedProfileUid = null;
      } else if (_currentUser?.id != user.uid) {
        // Yeni/kalıcı oturum: temel bilgiyi kur, detayları Firestore'dan çek.
        _currentUser = UserModel.fromUser(user);
        _loadUserProfile(user.uid);
      }
      _isLoading = false;
      _errorMessage = null;
      _userRepository.setUserId(user?.uid ?? '');
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        await _loadUserProfile(user.uid);
      }
    } on FirebaseErrors catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = Strings.errorUnknown;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kayıt olur.
  Future<void> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (user != null) {
        final record = UserModel.fromUser(user);
        await _userRepository.createUserRecord(record);
        _currentUser = record;
      }
    } on FirebaseErrors catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = Strings.errorUnknown;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google ile giriş yapar.
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _errorMessage = 'Google girişi iptal edildi.';
      }
    } on FirebaseErrors catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage =
          'Google girişi sırasında bir hata oluştu. SHA-1 parmak izini ve google-services.json dosyasını kontrol edin.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Profil verisini Firestore'dan yükler.
  Future<void> _loadUserProfile(String uid) async {
    if (_loadedProfileUid == uid) return;
    try {
      var record = await _userRepository.getCurrentUserRecord();
      if (record == null) {
        record = UserModel.fromUser(FirebaseAuth.instance.currentUser!);
        await _userRepository.createUserRecord(record);
      }
      _currentUser = record;
      _loadedProfileUid = uid;
    } on FirebaseErrors catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = Strings.errorUnknown;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Çıkış yapar.
  Future<void> signOut() async {
    try {
      _isLoading = true;
      await _authRepository.signOut();
      _currentUser = null;
      _loadedProfileUid = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = Strings.errorUnknown;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Profil bilgilerini günceller.
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _errorMessage = null;
      await _authRepository.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName,
          photoURL: photoURL,
        );
      }
    } on FirebaseErrors catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = Strings.errorUnknown;
    }
    notifyListeners();
  }

  /// Hesabı siler.
  Future<void> deleteAccount() async {
    try {
      _errorMessage = null;
      await _authRepository.deleteAccount();
      _currentUser = null;
    } on FirebaseErrors catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = Strings.errorUnknown;
    }
    notifyListeners();
  }
}
