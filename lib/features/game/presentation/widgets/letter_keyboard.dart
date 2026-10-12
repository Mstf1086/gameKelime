import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/game_utils.dart';
import '../providers/game_provider.dart';
import '../providers/keyboard_provider.dart';

class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final keyboard = context.watch<KeyboardProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rows = GameUtils.getKeyboardRows();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: row.map((letter) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _KeyboardKey(
                          letter: letter,
                          isActive: game.activeKeys.contains(letter),
                          isPressed: keyboard.isPressed(letter) ||
                              game.guessedLetters.contains(letter) ||
                              game.wrongLetters.contains(letter),
                          isCorrect: game.guessedLetters.contains(letter),
                          isWrong: game.wrongLetters.contains(letter),
                          onTap: () => _handleKeyTap(context, letter),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _handleKeyTap(BuildContext context, String letter) {
    final game = context.read<GameProvider>();
    final keyboard = context.read<KeyboardProvider>();
    if (game.isGameOver) return;

    keyboard.pressKey(letter);
    game.guessLetter(letter);
  }
}

class _KeyboardKey extends StatelessWidget {
  final String letter;
  final bool isActive;
  final bool isPressed;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _KeyboardKey({
    required this.letter,
    required this.isActive,
    required this.isPressed,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  Color _backgroundColor() {
    if (isCorrect) return AppColors.success;
    if (isWrong) return AppColors.danger;
    if (isActive) return AppColors.keyboardKeyActive;
    return AppColors.keyboardKey;
  }

  Color _textColor() {
    if (isCorrect || isWrong) return Colors.white;
    if (isActive) return Colors.white;
    return AppColors.textPrimaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor(),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isPressed ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textColor(),
            ),
          ),
        ),
      ),
    );
  }
}
