import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/game/presentation/pages/home_page.dart';
import 'features/game/presentation/pages/level_select_page.dart';
import 'features/game/presentation/pages/game_page.dart';
import 'features/game/presentation/pages/game_result_page.dart';
import 'features/game/presentation/pages/rules_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/leaderboard_page.dart';
import 'features/profile/presentation/pages/game_history_page.dart';

class AppPages {
  AppPages._();

  // Rota adları
  static const String welcome = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String levelSelect = '/level-select';
  static const String game = '/game';
  static const String gameResult = '/game-result';
  static const String rules = '/rules';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String history = '/history';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return _pageRoute(const WelcomePage(), settings);
      case signIn:
        return _pageRoute(const SignInPage(), settings);
      case signUp:
        return _pageRoute(const SignUpPage(), settings);
      case home:
        return _pageRoute(const HomePage(), settings);
      case levelSelect:
        return _pageRoute(const LevelSelectPage(), settings);
      case game:
        return _pageRoute(GamePage(settings: settings), settings);
      case gameResult:
        return _pageRoute(GameResultPage(settings: settings), settings);
      case rules:
        return _pageRoute(const RulesPage(), settings);
      case profile:
        return _pageRoute(const ProfilePage(), settings);
      case leaderboard:
        return _pageRoute(const LeaderboardPage(), settings);
      case history:
        return _pageRoute(const GameHistoryPage(), settings);
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _pageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, ___, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<dynamic> _errorRoute() {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => const Scaffold(
        body: Center(
          child: Text('Sayfa bulunamadı', style: TextStyle(fontSize: 18)),
        ),
      ),
      transitionsBuilder: (_, animation, ___, child) => child,
      transitionDuration: Duration.zero,
    );
  }
}
