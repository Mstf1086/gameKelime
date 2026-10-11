import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../providers/game_provider.dart';

class LetterBox extends StatelessWidget {
  final int index;

  const LetterBox({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final level = game.level;
    if (level == null) return const SizedBox.shrink();

    final letter = level.answer[index].toUpperCase();
    final revealed = game.guessedLetters.contains(letter);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: revealed ? AppColors.success : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: revealed ? AppColors.success : AppColors.letterBoxDefault,
          width: 2,
        ),
        boxShadow: revealed
            ? [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          revealed ? letter : '_',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: revealed ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
