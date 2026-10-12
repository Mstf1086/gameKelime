import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/routes/app_pages.dart';
import '../../../../core/services/timer_service.dart';
import '../../../../core/utils/game_utils.dart';
import '../../../../core/services/level_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/keyboard_provider.dart';
import '../widgets/score_board.dart';
import '../widgets/question_card.dart';
import '../widgets/letter_box.dart';
import '../widgets/joker_buttons.dart';
import '../widgets/system_keyboard_input.dart';
import '../widgets/timer_widget.dart';

class GamePage extends StatefulWidget {
  final RouteSettings? settings;
  const GamePage({super.key, this.settings});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final GameProvider _gameProvider;
  late final KeyboardProvider _keyboardProvider;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _gameProvider = GameProvider(
      timerService: context.read<TimerService>(),
    );
    _keyboardProvider = KeyboardProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  Future<void> _startGame() async {
    final args = widget.settings?.arguments as Map<String, dynamic>?;
    final levelService = context.read<LevelService>();
    int levelNumber = args?['level'] as int? ?? 1;

    await levelService.startLevel(levelNumber);
    final level = levelService.currentLevel;
    if (level != null) {
      _gameProvider.startLevel(level);
      _keyboardProvider.reset();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Strings.errorLevelNotFound)),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _gameProvider.dispose();
    _keyboardProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _gameProvider),
        ChangeNotifierProvider.value(value: _keyboardProvider),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.appTitleShort),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmLeave(context),
          ),
        ),
        body: SafeArea(
          child: Consumer<GameProvider>(
            builder: (_, game, __) {
              if (game.level == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (game.isGameOver) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _goToResult(context, game);
                });
              }

              return Column(
                children: [
                  const ScoreBoard(),
                  const TimerWidget(),
                  const SizedBox(height: 12),
                  QuestionCard(
                    category: game.level!.category,
                    question: game.level!.question,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            game.level!.answer.length,
                            (index) => LetterBox(index: index),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const JokerButtons(),
                  const SizedBox(height: 8),
                  const SystemKeyboardInput(),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Oyundan Çık'),
        content: const Text('Oyundan çıkmak istediğinize emin misiniz? İlerlemeniz kaydedilmeyebilir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.noButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(Strings.yesButton),
          ),
        ],
      ),
    );
  }

  Future<void> _goToResult(BuildContext context, GameProvider game) async {
    if (_resultShown || !mounted) return;
    _resultShown = true;

    // Oyun sonucunu + seviye ilerlemesini Firestore'a kaydet.
    final uid = context.read<AuthProvider>().currentUser?.id;
    if (uid != null) {
      await game.saveGameRecord(userId: uid);
    }
    if (!mounted) return;
    if (game.isWin && game.level != null) {
      context.read<LevelService>().unlockLevel(game.level!.level + 1);
    }

    Navigator.of(context).pushReplacementNamed(
      AppPages.gameResult,
      arguments: {
        'level': game.level!.level,
        'word': game.level!.answer,
        'score': game.score,
        'win': game.isWin,
      },
    );
  }
}
