import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/constants/colors.dart';
import 'core/constants/strings.dart';
import 'core/constants/game_config.dart';
import 'core/routes/app_pages.dart';
import 'features/game/presentation/providers/game_provider.dart';
import 'features/game/presentation/providers/keyboard_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/timer_service.dart';
import 'core/services/level_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestore kullanan servisleri başlat
  await FirestoreService().init();

  runApp(const GameKelimeApp());
}

class GameKelimeApp extends StatelessWidget {
  const GameKelimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TimerService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LevelService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => KeyboardProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<ThemeService>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title: Strings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppColors.lightTheme,
            darkTheme: AppColors.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppPages.welcome,
            onGenerateRoute: AppPages.onGenerateRoute,
          );
        },
      ),
    );
  }
}
