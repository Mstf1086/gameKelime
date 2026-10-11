import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Auth işlemlerini yöneten servis.
/// AuthProvider tarafından kullanılır, bu servis soyutlama sağlar.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '750201021877-fp2pvpvdkvf1h6qgijmnciprfqfou0kki.apps.googleusercontent.com',
  );

  User? _currentUser;
  bool _isAuthLoading = true;
  String? _lastError;

  User? get currentUser => _currentUser;
  bool get isAuthLoading => _isAuthLoading;
  String? get lastError => _lastError;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    _initAuthState();
  }

  void _initAuthState() {
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      _isAuthLoading = false;
      _lastError = null;
      notifyListeners();
    });
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _lastError = null;
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
      notifyListeners();
      return {'success': true, 'user': credential.user};
    } on FirebaseAuthException catch (e) {
      _lastError = _translateAuthError(e.code);
      return {'success': false, 'error': _lastError};
    } catch (e) {
      _lastError = 'Giriş sırasında bir hata oluştu.';
      return {'success': false, 'error': _lastError};
    }
  }

  Future<Map<String, dynamic>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _lastError = null;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      _currentUser = credential.user;
      notifyListeners();
      return {'success': true, 'user': credential.user};
    } on FirebaseAuthException catch (e) {
      _lastError = _translateAuthError(e.code);
      return {'success': false, 'error': _lastError};
    } catch (e) {
      _lastError = 'Kayıt sırasında bir hata oluştu.';
      return {'success': false, 'error': _lastError};
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      _lastError = null;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'error': 'Google girişi iptal edildi.'};
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _auth.signInWithCredential(credential);
      _currentUser = userCredential.user;
      notifyListeners();
      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      _lastError = _translateAuthError(e.code);
      return {'success': false, 'error': _lastError};
    } catch (e) {
      _lastError = 'Google girişi sırasında bir hata oluştu.';
      return {'success': false, 'error': _lastError};
    }
  }

  String _translateAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı.';
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı hesap bulunamadı.';
      case 'wrong-password':
        return 'E-posta veya şifre hatalı.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı kontrol edin.';
      default:
        return 'Giriş hatası: ${code.replaceAll('-', ' ')}';
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _lastError = 'Çıkış yapılırken bir hata oluştu.';
      notifyListeners();
    }
  }

  /// Profil bilgilerini güncelle (ad, fotoğraf).
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      _lastError = null;
      final user = _currentUser;
      if (user == null) throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Kullanıcı oturum açmamış.',
      );
      await user.updateDisplayName(displayName);
      if (photoURL != null) await user.updatePhotoURL(photoURL);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _lastError = _translateAuthError(e.code);
    } catch (e) {
      _lastError = 'Profil güncellenirken bir hata oluştu.';
    }
    notifyListeners();
  }

  /// Hesabı siler (kullanıcı onayı gereklidir).
  Future<void> deleteAccount() async {
    try {
      _lastError = null;
      final user = _currentUser;
      if (user == null) throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Kullanıcı oturum açmamış.',
      );
      await user.delete();
      _currentUser = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _lastError = _translateAuthError(e.code);
    } catch (e) {
      _lastError = 'Hesap silinirken bir hata oluştu.';
    }
    notifyListeners();
  }
}
