import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/mock_data.dart';
import '../models/product_model.dart';
import 'product_quick_view_sheet.dart';
import 'shadcn/shadcn_badge.dart';
import 'shadcn/shadcn_button.dart';
import 'shadcn/shadcn_card.dart';
import 'shadcn/shadcn_dialog.dart';

class ScentQuizModal extends StatefulWidget {
  const ScentQuizModal({super.key});

  static void show(BuildContext context) {
    ShadcnDialog.show(
      context: context,
      title: '✨ Find Your Signature Scent',
      description: 'Answer 2 quick questions to discover your personalized fragrance match.',
      child: const ScentQuizModal(),
    );
  }

  @override
  State<ScentQuizModal> createState() => _ScentQuizModalState();
}

class _ScentQuizModalState extends State<ScentQuizModal> {
  int _currentStep = 1;
  String? _selectedFamily;
  String? _selectedOccasion;
  ProductModel? _matchedProduct;

  final List<Map<String, dynamic>> _vibeOptions = [
    {
      'family': 'Woody',
      'label': 'Warm, Smoky & Regal Oud',
      'icon': Icons.forest_rounded,
      'desc': 'Cedarwood, Royal Oud, Smoky Incense',
    },
    {
      'family': 'Fresh',
      'label': 'Crisp Citrus & Sea Breeze',
      'icon': Icons.water_drop_rounded,
      'desc': 'Amalfi Lemon, Crushed Mint, Marine',
    },
    {
      'family': 'Floral',
      'label': 'Sensual Velvet Flowers',
      'icon': Icons.local_florist_rounded,
      'desc': 'Damask Rose, Iris, Magnolia',
    },
    {
      'family': 'Gourmand',
      'label': 'Sweet Vanilla & Dark Rum',
      'icon': Icons.cookie_rounded,
      'desc': 'Madagascar Vanilla, Roasted Coffee, Caramel',
    },
    {
      'family': 'Amber & Oud',
      'label': 'Opulent Amber & Precious Resins',
      'icon': Icons.brightness_7_rounded,
      'desc': 'Golden Amber, Cardamom, Resins',
    },
  ];

  final List<Map<String, dynamic>> _occasionOptions = [
    {'name': 'Evening Gala', 'icon': Icons.nightlife_rounded},
    {'name': 'Everyday Luxury', 'icon': Icons.wb_sunny_rounded},
    {'name': 'Executive Signature', 'icon': Icons.business_center_rounded},
    {'name': 'Date Night', 'icon': Icons.favorite_rounded},
    {'name': 'Summer Escape', 'icon': Icons.beach_access_rounded},
  ];

  void _calculateMatch() {
    final matches = MockData.products.where((p) {
      final familyMatch = p.fragranceFamily == _selectedFamily;
      final occasionMatch = p.occasion == _selectedOccasion;
      return familyMatch || occasionMatch;
    }).toList();

    setState(() {
      _matchedProduct = matches.isNotEmpty ? matches.first : MockData.products.first;
      _currentStep = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 1 of 2: What scent vibe attracts you most?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentGold),
          ),
          const SizedBox(height: 12),
          ..._vibeOptions.map((opt) {
            final isSel = _selectedFamily == opt['family'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShadcnCard(
                variant: isSel ? ShadcnCardVariant.glass : ShadcnCardVariant.defaultCard,
                onTap: () {
                  setState(() {
                    _selectedFamily = opt['family'];
                    _currentStep = 2;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primary : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(opt['icon'] as IconData, color: isSel ? Colors.white : AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['label'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            opt['desc'] as String,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isSel ? AppColors.primary : AppColors.textLight),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    }

    if (_currentStep == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 18),
                onPressed: () => setState(() => _currentStep = 1),
              ),
              const Text(
                'Step 2 of 2: Where will you wear it?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._occasionOptions.map((opt) {
            final name = opt['name'] as String;
            final isSel = _selectedOccasion == name;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShadcnCard(
                variant: isSel ? ShadcnCardVariant.glass : ShadcnCardVariant.defaultCard,
                onTap: () {
                  _selectedOccasion = name;
                  _calculateMatch();
                },
                child: Row(
                  children: [
                    Icon(opt['icon'] as IconData, color: AppColors.primary, size: 22),
                    const SizedBox(width: 14),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    const Icon(Icons.check_circle_outline, color: AppColors.accentGold, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    }

    // Step 3: Result
    final p = _matchedProduct!;
    return Column(
      children: [
        const Icon(Icons.auto_awesome_rounded, color: AppColors.accentGold, size: 40),
        const SizedBox(height: 8),
        const Text(
          'YOUR PERFECT FRAGRANCE MATCH',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 6),
        Text(
          p.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'by ${p.brand}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.network(p.mainImage, fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShadcnBadge(label: p.fragranceFamily, variant: ShadcnBadgeVariant.gold),
            const SizedBox(width: 8),
            ShadcnBadge(label: p.longevity, variant: ShadcnBadgeVariant.secondary),
          ],
        ),

        const SizedBox(height: 12),
        Text(
          p.description,
          maxLines: 3,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),

        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ShadcnButton(
                text: 'Inspect & Quick View',
                variant: ShadcnButtonVariant.outline,
                onPressed: () {
                  Navigator.pop(context);
                  ProductQuickViewSheet.show(context, p);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ShadcnButton(
                text: 'Try Again',
                variant: ShadcnButtonVariant.ghost,
                onPressed: () => setState(() => _currentStep = 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
