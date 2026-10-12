import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../data/models/stats_model.dart';
import '../widgets/stats_card.dart';
import '../widgets/user_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<ProfileProvider>().loadStats(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.profileTitle),
        actions: [
          IconButton(
            onPressed: () => _showEditProfileDialog(context),
            icon: const Icon(Icons.edit_outlined),
            tooltip: Strings.editProfileButton,
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<ProfileProvider>()
                    .loadStats(context.read<AuthProvider>());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(context, authProvider),
                    const SizedBox(height: 20),
                    if (profileProvider.stats != null)
                      _buildStatsGrid(context, profileProvider.stats!)
                    else if (profileProvider.errorMessage != null)
                      Center(child: Text(profileProvider.errorMessage!))
                    else
                      const Center(child: Text('Henüz istatistik yok.')),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    return Column(
      children: [
        const UserAvatar(),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? Strings.appTitleShort,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          user?.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProfileStats stats) {
    return Column(
          children: [
            StatsCard(title: Strings.totalScoreLabel, value: '${stats.totalScore}', icon: Icons.score),
            const SizedBox(height: 12),
            StatsCard(title: Strings.levelsUnlockedLabel, value: '${stats.levelReached}', icon: Icons.flag),
            const SizedBox(height: 12),
            StatsCard(title: Strings.gamesPlayedLabel, value: '${stats.gamesPlayed}', icon: Icons.play_arrow),
            const SizedBox(height: 12),
            StatsCard(title: Strings.gamesWonLabel, value: '${stats.gamesWon}', icon: Icons.check_circle),
            const SizedBox(height: 12),
            StatsCard(title: Strings.streakLabel, value: '${stats.streak}', icon: Icons.local_fire_department),
            const SizedBox(height: 12),
            StatsCard(title: Strings.bestScoreLabel, value: '${stats.bestScore}', icon: Icons.star),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showDeleteAccountDialog(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text(Strings.deleteAccountButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showChangePasswordDialog(context),
              icon: const Icon(Icons.lock_outline),
              label: const Text(Strings.changePasswordButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppPages.welcome);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text(Strings.logOutButton),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
            ),
          ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nameController = TextEditingController(
      text: auth.currentUser?.displayName ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profili Düzenle'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Ad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.noButton),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().updateProfile(displayName: nameController.text.trim());
              Navigator.of(context).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil güncellendi.')),
                );
              }
            },
            child: const Text(Strings.continueButton),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(Strings.confirmDeleteAccount),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.noButton),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppPages.welcome);
              }
            },
            child: const Text(Strings.yesButton, style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifre değiştirme özelliği yakında eklenecek.')),
    );
  }
}
