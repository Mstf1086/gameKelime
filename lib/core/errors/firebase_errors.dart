import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase ile ilgili tüm özel hatalar.
class FirebaseErrors implements Exception {
  final String message;
  final dynamic originalError;

  const FirebaseErrors(this.message, {this.originalError});

  factory FirebaseErrors.firestoreError(FirebaseException e) {
    return FirebaseErrors(_mapFirestoreErrorCode(e.code));
  }

  factory FirebaseErrors.authError(String code, {String? customMessage}) {
    return FirebaseErrors(customMessage ?? _mapAuthErrorCode(code));
  }

  factory FirebaseErrors.levelNotFound(int level) {
    return FirebaseErrors('Seviye $level bulunamadı.');
  }

  factory FirebaseErrors.firestoreNotInitialized(String message) {
    return FirebaseErrors(message);
  }

  factory FirebaseErrors.unauthorized() {
    return const FirebaseErrors('Bu işlem için yetkiniz yok.');
  }

  static String _mapFirestoreErrorCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Bu veriye erişim yetkiniz yok.';
      case 'unavailable':
        return 'Firestore hizmetine erişilemiyor. Bağlantıyı kontrol edin.';
      case 'not-found':
        return 'Belge bulunamadı.';
      default:
        return 'Firestore hatası: $code';
    }
  }

  static String _mapAuthErrorCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı.';
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'E-posta veya şifre hatalı.';
      case 'user-disabled':
        return 'Bu hesap devre dışı.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı kontrol edin.';
      default:
        return 'Kimlik doğrulama hatası: $code';
    }
  }

  @override
  String toString() => 'FirebaseError: $message';
}
