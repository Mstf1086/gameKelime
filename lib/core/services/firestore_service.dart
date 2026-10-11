import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/strings.dart';
import '../errors/firebase_errors.dart';

/// Firestore erişimlerini yöneten servis. Singleton olarak kullanılır.
class FirestoreService extends ChangeNotifier {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  static FirestoreService? _initializedInstance;

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore {
    if (_firestore == null) {
      _firestore = FirebaseFirestore.instance;
    }
    return _firestore;
  }

  /// Firestore'ı başlatır ( FirestoreService.instance ile erişilir).
  Future<void> init() async {
    _initializedInstance = this;
    _firestore ??= FirebaseFirestore.instance;
    notifyListeners();
  }

  static FirestoreService get instance {
    if (_initializedInstance == null) {
      throw FirebaseErrors.firestoreNotInitialized(
        Strings.errorFirestoreUninitialized,
      );
    }
    return _initializedInstance!;
  }

  // -----------------------------------------------------------------
  // Genel CRUD operasyonları
  // -----------------------------------------------------------------

  /// Bir koleksiyona belge ekler.
  Future<DocumentReference<Map<String, dynamic>>> add(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      assert(firestore != null, Strings.errorFirestoreUninitialized);
      return (await firestore!.collection(collectionPath).add(data));
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// Bir koleksiyondaki tüm belgeleri okur (snapshot bazında).
  Future<List<Map<String, dynamic>>> collectionCollection(String collectionPath) {
    return _snapshotToList(collection(collectionPath));
  }

  Stream<List<Map<String, dynamic>>> collectionStream(String collectionPath) {
    return _snapshotToStream(collection(collectionPath));
  }

  /// Bir kullanıcının koleksiyonundaki belgeleri okur.
  Future<List<Map<String, dynamic>>> userCollection(
    String collectionPath,
    String userId,
  ) async {
    try {
      assert(firestore != null, Strings.errorFirestoreUninitialized);
      final snapshot = await firestore!
          .collection(collectionPath)
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  Stream<List<Map<String, dynamic>>> userCollectionStream(
    String collectionPath,
    String userId,
  ) {
    return _snapshotToStream(
      firestore!.collection(collectionPath).where('userId', isEqualTo: userId),
    );
  }

  /// ID'e göre belge okur.
  Future<Map<String, dynamic>?> documentGet(String path) async {
    try {
      assert(firestore != null, Strings.errorFirestoreUninitialized);
      final doc = await firestore!.doc(path).get();
      if (!doc.exists) return null;
      final data = doc.data()! as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// ID'e göre belgeyi günceller (mevcut veriyi korur).
  Future<void> documentUpdate(String path, Map<String, dynamic> data) async {
    try {
      assert(firestore != null, Strings.errorFirestoreUninitialized);
      await firestore!.doc(path).update(data);
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  /// ID'e göre belgeyi siler.
  Future<void> documentDelete(String path) async {
    try {
      assert(firestore != null, Strings.errorFirestoreUninitialized);
      await firestore!.doc(path).delete();
    } on FirebaseException catch (e) {
      throw FirebaseErrors.firestoreError(e);
    }
  }

  // -----------------------------------------------------------------
  // Koleksiyon ve snapshot yardımcıları
  // -----------------------------------------------------------------

  Query<Map<String, dynamic>> collection(String path) {
    return firestore!.collection(path).orderBy('level');
  }

  Future<List<Map<String, dynamic>>> _snapshotToList(
    Query<Map<String, dynamic>> query,
  ) async {
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> _snapshotToStream(
    Query<Map<String, dynamic>> query,
  ) {
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Sıralama ve filtreleme ile belge başlatır (gameRecords sıralaması için).
  Query<Map<String, dynamic>> orderedCollection(String path, {String orderBy = 'createdAt', bool descending = true}) {
    Query<Map<String, dynamic>> query = collection(path);
    if (orderBy.isNotEmpty) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query;
  }
}
