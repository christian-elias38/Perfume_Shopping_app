import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../widgets/luxury_background.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Categories'),
      ),
      body: LuxuryBackground(
        child: categoriesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, _) =>
              const Center(child: Text('Unable to load categories')),
          data: (categories) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = cat.id;
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    height: 130,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(cat.imageUrl, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppColors.primaryDark.withValues(alpha: 0.92),
                                AppColors.primaryDark.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.description ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
