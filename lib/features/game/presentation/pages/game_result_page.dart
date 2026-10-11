import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/game_provider.dart';

class GameResultPage extends StatelessWidget {
  final RouteSettings? settings;
  const GameResultPage({super.key, this.settings});

  @override
  Widget build(BuildContext context) {
    final args = settings?.arguments as Map<String, dynamic>?;
    final win = args?['win'] as bool? ?? false;
    final word = args?['word'] as String? ?? '';
    final score = args?['score'] as int? ?? 0;
    final level = args?['level'] as int? ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                win ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 120,
                color: win ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(height: 24),
              Text(
                win ? Strings.gameWonTitle : Strings.gameLostTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: win ? AppColors.success : AppColors.danger,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${Strings.gameResultMessage} $word',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${Strings.scoreLabel}: $score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (win) {
                    Navigator.of(context).pushReplacementNamed(
                      AppPages.game,
                      arguments: {'level': level + 1},
                    );
                  } else {
                    Navigator.of(context).pushReplacementNamed(
                      AppPages.game,
                      arguments: {'level': level},
                    );
                  }
                },
                child: Text(win ? 'Sonraki Seviye' : Strings.retryButton),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppPages.home);
                },
                child: const Text(Strings.homeButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
