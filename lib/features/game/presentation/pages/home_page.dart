import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../core/services/level_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.homeTitle),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppPages.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, user?.displayName ?? '', user?.totalScore ?? 0),
              const SizedBox(height: 24),
              _buildMenuCard(
                context,
                title: 'Oyna',
                subtitle: 'Kolaydan zora kelime tahmin et',
                icon: Icons.play_arrow_rounded,
                onTap: () => Navigator.of(context).pushNamed(AppPages.levelSelect),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: Strings.rulesTitle,
                subtitle: 'Oyun kurallarını gör',
                icon: Icons.rule_rounded,
                onTap: () => _showRules(context),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: Strings.leaderboardTitle,
                subtitle: 'En yüksek skorları gör',
                icon: Icons.emoji_events_outlined,
                onTap: () => Navigator.of(context).pushNamed(AppPages.leaderboard),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: Strings.historyTitle,
                subtitle: 'Geçmiş oyun kayıtların',
                icon: Icons.history,
                onTap: () => Navigator.of(context).pushNamed(AppPages.history),
              ),
              const Spacer(),
              _buildSignOutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, int score) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Merhaba, ${name.isEmpty ? 'Oyuncu' : name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${Strings.totalScoreLabel}: $score',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return TextButton.icon(
      onPressed: () async {
        await authProvider.signOut();
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed(AppPages.welcome);
        }
      },
      icon: const Icon(Icons.logout, color: AppColors.danger),
      label: const Text(
        Strings.logOutButton,
        style: TextStyle(color: AppColors.danger),
      ),
    );
  }

  void _showRules(BuildContext context) {
    Navigator.of(context).pushNamed(AppPages.rules); // TODO: RulesPage
  }
}
