import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/mock_data.dart';
import '../../models/product_model.dart';
import '../product/product_detail_screen.dart';

class ScentQuizScreen extends StatefulWidget {
  const ScentQuizScreen({super.key});

  @override
  State<ScentQuizScreen> createState() => _ScentQuizScreenState();
}

class _ScentQuizScreenState extends State<ScentQuizScreen> {
  String? _selectedVibe;
  ProductModel? _match;

  final _vibes = [
    {
      'label': 'Romantic & Soft',
      'family': 'Floral',
      'image':
          'https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?auto=format&fit=crop&w=400&q=80',
    },
    {
      'label': 'Bold & Confident',
      'family': 'Spicy',
      'image':
          'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=400&q=80',
    },
    {
      'label': 'Fresh & Clean',
      'family': 'Fresh',
      'image':
          'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=400&q=80',
    },
    {
      'label': 'Warm & Cozy',
      'family': 'Gourmand',
      'image':
          'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=400&q=80',
    },
  ];

  void _findMatch() {
    if (_selectedVibe == null) return;
    final family = _vibes.firstWhere((v) => v['label'] == _selectedVibe)['family'] as String;
    final matches = MockData.products
        .where((p) => p.fragranceFamily.toLowerCase() == family.toLowerCase())
        .toList();
    setState(() => _match = matches.isNotEmpty ? matches.first : MockData.products.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scent Finder'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _match == null ? _buildQuiz() : _buildResult(),
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What kind of vibe\nare you looking for?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the mood that speaks to you',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _vibes.length,
            itemBuilder: (context, i) {
              final vibe = _vibes[i];
              final selected = _selectedVibe == vibe['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedVibe = vibe['label'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? AppColors.accentGold : Colors.white24,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(vibe['image'] as String, fit: BoxFit.cover),
                      Container(color: Colors.black.withValues(alpha: 0.45)),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            vibe['label'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedVibe == null ? null : _findMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryDark,
              disabledBackgroundColor: AppColors.accentGold.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('Find My Scent', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final p = _match!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Signature Match',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(p.imageUrls.first, height: 220, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(p.brand, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('View Product'),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _match = null;
              _selectedVibe = null;
            }),
            child: const Text('Retake Quiz', style: TextStyle(color: AppColors.accentGold)),
          ),
        ),
      ],
    );
  }
}
