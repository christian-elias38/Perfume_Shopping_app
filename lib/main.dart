import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (with fallback to offline demo mode if unconfigured)
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: PerfumeShoppingApp(),
    ),
  );
}

class PerfumeShoppingApp extends StatelessWidget {
  const PerfumeShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parfumerie - Haute Parfumerie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
