import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../providers/game_provider.dart';

class JokerButtons extends StatelessWidget {
  const JokerButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _JokerButton(
            icon: Icons.lightbulb_outline,
            label: Strings.joker1Label,
            tooltip: Strings.joker1Desc,
            available: game.hasJoker1,
            onTap: () => game.useJoker1(),
          ),
          _JokerButton(
            icon: Icons.backspace_outlined,
            label: Strings.joker2Label,
            tooltip: Strings.joker2Desc,
            available: game.hasJoker2,
            onTap: () => game.useJoker2(),
          ),
          _JokerButton(
            icon: Icons.score_outlined,
            label: Strings.joker3Label,
            tooltip: Strings.joker3Desc,
            available: game.hasJoker3,
            onTap: () => game.useJoker3(),
          ),
        ],
      ),
    );
  }
}

class _JokerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool available;
  final VoidCallback onTap;

  const _JokerButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: available ? 1.0 : 0.4,
          child: Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: available
                  ? AppColors.warning.withOpacity(0.15)
                  : AppColors.letterBoxDefault.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: available ? AppColors.warning : AppColors.letterBoxDefault,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: available ? AppColors.warning : AppColors.textSecondaryLight),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: available
                            ? AppColors.textPrimaryLight
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
