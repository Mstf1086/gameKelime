import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/errors/firebase_errors.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Giriş/kayıt akışını yöneten state provider.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
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
      _currentUser = user != null ? UserModel.fromUser(user) : null;
      _isLoading = false;
      _errorMessage = null;
      _userRepository.setUserId(user?.uid);
      notifyListeners();
    });
  }

  /// Giriş yapar.
  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
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
    try {
      _isLoading = true;
      _errorMessage = null;
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
    try {
      _isLoading = true;
      _errorMessage = null;
      final user = await _authRepository.signInWithGoogle();
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

  /// Profil verisini Firestore'dan yükler.
  Future<void> _loadUserProfile(String uid) async {
    try {
      var record = await _userRepository.getCurrentUserRecord();
      if (record == null) {
        record = UserModel.fromUser(FirebaseAuth.instance.currentUser!);
        await _userRepository.createUserRecord(record);
      }
      _currentUser = record;
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
