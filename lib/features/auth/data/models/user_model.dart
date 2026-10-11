import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore'daki user belgesine karşılık gelen model.
class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoURL;
  final int totalScore;
  final int levelReached;
  final int gamesWon;
  final int gamesPlayed;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.totalScore = 0,
    this.levelReached = 1,
    this.gamesWon = 0,
    this.gamesPlayed = 0,
    this.createdAt,
  });

  /// Firestore belgesinden model oluşturur.
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoURL: data['photoURL'] as String?,
      totalScore: data['totalScore'] as int? ?? 0,
      levelReached: data['levelReached'] as int? ?? 1,
      gamesWon: data['gamesWon'] as int? ?? 0,
      gamesPlayed: data['gamesPlayed'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firebase Auth User nesnesinden model oluşturur.
  factory UserModel.fromUser(User user) {
    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoURL: user.photoURL,
    );
  }

  /// Firestore yazımı için belge verisine çevirir.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'totalScore': totalScore,
      'levelReached': levelReached,
      'gamesWon': gamesWon,
      'gamesPlayed': gamesPlayed,
      'createdAt': createdAt ?? Timestamp.now(),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? photoURL,
    int? totalScore,
    int? levelReached,
    int? gamesWon,
    int? gamesPlayed,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      totalScore: totalScore ?? this.totalScore,
      levelReached: levelReached ?? this.levelReached,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, displayName: $displayName, email: $email)';
}
