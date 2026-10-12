import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/game_config.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/services/level_service.dart';
import '../../data/models/level_model.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({super.key});

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = context.read<LevelService>();
      if (svc.availableLevels.isEmpty && !svc.isLoading) {
        svc.loadLevels();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelService = context.watch<LevelService>();
    final auth = context.watch<AuthProvider>();
    // Kullanıcının Firestore'daki kayıtlı seviyesi + servisteki kilit.
    final unlockedLevel = math.max(
      levelService.unlockedLevel,
      auth.currentUser?.levelReached ?? 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.levelSelectTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LevelService>().loadLevels(),
          ),
        ],
      ),
      body: levelService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : levelService.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          levelService.error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<LevelService>().loadLevels(),
                          child: const Text(Strings.retryButton),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildLevelGrid(context, levelService),
    );
  }

  Widget _buildLevelGrid(BuildContext context, LevelService levelService) {
    final levels = levelService.availableLevels;
    if (levels.isEmpty) {
      return const Center(child: Text('Henüz seviye eklenmedi. Firestore levels koleksiyonuna seviyeleri ekleyin.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isUnlocked = level.level <= unlockedLevel;
          return _LevelCard(
            level: level,
            isUnlocked: isUnlocked,
            onTap: () => _onLevelSelected(context, levelService, level, unlockedLevel),
          );
        },
      ),
    );
  }

  void _onLevelSelected(
    BuildContext context,
    LevelService levelService,
    LevelModel level,
    int unlockedLevel,
  ) {
    if (level.level > unlockedLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu seviye henüz kilitli.')),
      );
      return;
    }
    levelService.startLevel(level.level);
    Navigator.of(context).pushNamed(
      AppPages.game,
      arguments: {'level': level.level},
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelModel level;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.onTap,
  });

  Color _difficultyColor() {
    switch (level.difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnlocked ? null : Colors.grey.shade200,
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _difficultyColor().withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        '${level.level}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _difficultyColor(),
                        ),
                      )
                    : Icon(Icons.lock, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              level.category,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${level.basePoints} puan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _difficultyColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
