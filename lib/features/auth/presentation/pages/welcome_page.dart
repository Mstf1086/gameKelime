import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/services/theme_service.dart';
import '../providers/auth_provider.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeService>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            _buildLogo(context),
            const SizedBox(height: 32),
            Text(
              Strings.appTitleShort,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                Strings.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ),
            const Spacer(flex: 2),
            _buildActions(context, themeProvider),
            const Spacer(),
            Text(
              'Kelime Oyunu v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppPages.signIn);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 56),
          ),
          child: const Text(
            Strings.signInButton,
            style: TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppPages.signUp);
          },
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: AppColors.letterBoxEnabled, width: 2),
            minimumSize: const Size(200, 56),
          ),
          child: Text(
            Strings.signUpButton,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        IconButton(
          onPressed: themeProvider.toggleTheme,
          icon: Icon(
            themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            size: 30,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
