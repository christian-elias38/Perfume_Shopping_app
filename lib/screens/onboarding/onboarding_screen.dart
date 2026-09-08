import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _storyPages = [
    {
      'title': 'Elegance In Every Spray',
      'subtitle':
          'Discover haute parfumerie from the world\'s most prestigious niche perfume houses.',
      'image':
          'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Crafted By Master Perfumers',
      'subtitle':
          'Rare ingredients, long-lasting projection, and unforgettable olfactory signatures.',
      'image':
          'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=1000&q=80',
    },
    {
      'title': 'Find Your Signature Scent',
      'subtitle':
          'Sample luxury decants or full bottles delivered with white-glove luxury care.',
      'image':
          'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=1000&q=80',
    },
  ];

  static const _valueProps = [
    {
      'icon': Icons.verified_outlined,
      'title': 'Authentic Products',
      'subtitle': '100% genuine fragrances from trusted houses',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Fast & Secure Delivery',
      'subtitle': 'White-glove packaging shipped to your door',
    },
    {
      'icon': Icons.diamond_outlined,
      'title': 'Exclusive Collections',
      'subtitle': 'Rare decants and limited-edition releases',
    },
  ];

  int get _totalPages => _storyPages.length + 1;
  bool get _isValuesPage => _currentIndex == _storyPages.length;
  bool get _isLastPage => _currentIndex == _totalPages - 1;

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _onNext() {
    if (_isLastPage) {
      _goToMain();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              if (index < _storyPages.length) {
                return _StorySlide(page: _storyPages[index]);
              }
              return const _ValuesSlide();
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: TextButton(
                  onPressed: _goToMain,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: List.generate(_totalPages, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? AppColors.accentGold
                            : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                if (!_isValuesPage) ...[
                  const SizedBox(height: 24),
                  Text(
                    _storyPages[_currentIndex]['title']!,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _storyPages[_currentIndex]['subtitle']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isLastPage ? 'Explore Catalog' : 'Continue',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StorySlide extends StatelessWidget {
  final Map<String, String> page;

  const _StorySlide({required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(page['image']!, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark.withValues(alpha: 0.35),
                AppColors.primaryDark.withValues(alpha: 0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _ValuesSlide extends StatelessWidget {
  const _ValuesSlide();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundGradientStart, AppColors.backgroundGradientEnd],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 80, 28, 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PARFUMERIE',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Why choose us',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ..._OnboardingScreenState._valueProps.map((prop) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentGoldLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            prop['icon'] as IconData,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prop['title'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prop['subtitle'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
