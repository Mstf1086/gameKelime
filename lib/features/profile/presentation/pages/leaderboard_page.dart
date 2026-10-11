import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ProfileProvider>().getLeaderboard();
  }

  Future<void> _refresh() async {
    final rows = await context.read<ProfileProvider>().getLeaderboard();
    setState(() => _future = Future.value(rows));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.leaderboardTitle),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error.toString().replaceAll('FirebaseError: ', '');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(err, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text(Strings.retryButton),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz skor kaydı yok.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                final isCurrentUser =
                    user['id'] == context.read<AuthProvider>().currentUser?.id;
                return _LeaderboardRow(
                  rank: index + 1,
                  name: user['displayName'] as String? ?? 'Anonim',
                  score: user['totalScore'] as int? ?? 0,
                  isCurrentUser: isCurrentUser,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.score,
    required this.isCurrentUser,
  });

  IconData _getMedalIcon() {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.star_border;
      default:
        return Icons.numbers;
    }
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCurrentUser ? AppColors.primary.withOpacity(0.08) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor().withOpacity(0.2),
          child: Icon(_getMedalIcon(), color: _getRankColor()),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
            color: isCurrentUser ? AppColors.primary : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: isCurrentUser
            ? const Text('Sizin skorunuz',
                style: TextStyle(fontSize: 11, color: AppColors.primary))
            : null,
        trailing: Text(
          '$score',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
      ),
    );
  }
}
