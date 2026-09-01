import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      'title': 'Elegance In Every Spray',
      'subtitle': 'Discover haute parfumerie from the world\'s most prestigious niche perfume houses.',
      'image': 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Crafted By Master Perfumers',
      'subtitle': 'Rare ingredients, long-lasting projection, and unforgettable olfactory signatures.',
      'image': 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Find Your Signature Scent',
      'subtitle': 'Sample luxury decants or full bottles delivered with white-glove luxury care.',
      'image': 'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=1000&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Image PageView with Gradient Mask
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    pages[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryDark.withOpacity(0.4),
                          AppColors.primaryDark.withOpacity(0.95),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                );
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bottom Content Overlay
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? AppColors.accentGold : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Text(
                  pages[_currentIndex]['title']!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  pages[_currentIndex]['subtitle']!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: _currentIndex == pages.length - 1 ? 'EXPLORE CATALOG' : 'CONTINUE',
                  backgroundColor: AppColors.accentGold,
                  textColor: AppColors.primaryDark,
                  onPressed: () {
                    if (_currentIndex < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
