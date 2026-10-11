import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/game_config.dart';

/// Bir oyun seviyesini temsil eden model.
class LevelModel {
  final String id;
  final int level;
  String category;
  String question;
  String answer;
  String hint;
  Difficulty difficulty;
  final int basePoints;
  final int answerLength;

  LevelModel({
    required this.id,
    required this.level,
    required this.category,
    required this.question,
    required this.answer,
    required this.hint,
    this.difficulty = Difficulty.easy,
    required this.basePoints,
    required this.answerLength,
  });

  factory LevelModel.fromFirestore(Map<String, dynamic> data) {
    return LevelModel(
      id: data['id'] as String,
      level: data['level'] as int,
      category: data['category'] as String? ?? '',
      question: data['question'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
      hint: data['hint'] as String? ?? '',
      difficulty: GameConfig.difficultyForLevel(data['level'] as int?),
      basePoints: data['basePoints'] as int? ?? 0,
      answerLength: data['answerLength'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'level': level,
      'category': category,
      'question': question,
      'answer': answer,
      'hint': hint,
      'difficulty': _difficultyToString(difficulty),
      'basePoints': basePoints,
      'answerLength': answerLength,
    };
  }

  static String _difficultyToString(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 'easy';
      case Difficulty.medium:
        return 'medium';
      case Difficulty.hard:
        return 'hard';
    }
  }

  LevelModel copyWith({
    String? category,
    String? question,
    String? answer,
    String? hint,
    Difficulty? difficulty,
    int? basePoints,
    int? answerLength,
  }) {
    return LevelModel(
      id: id,
      level: level,
      category: category ?? this.category,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      hint: hint ?? this.hint,
      difficulty: difficulty ?? this.difficulty,
      basePoints: basePoints ?? this.basePoints,
      answerLength: answerLength ?? this.answerLength,
    );
  }

  @override
  String toString() =>
      'LevelModel(id: $id, level: $level, category: $category, answer: $answer)';
}
