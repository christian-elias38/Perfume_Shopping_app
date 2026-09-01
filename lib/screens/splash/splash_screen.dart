import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(color: AppColors.accentGold, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                size: 54,
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PARFUMERIE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elegance In Every Spray',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
