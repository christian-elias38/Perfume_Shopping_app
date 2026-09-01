import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LuxuryBackground extends StatefulWidget {
  final Widget child;
  final bool animateGlow;

  const LuxuryBackground({
    super.key,
    required this.child,
    this.animateGlow = true,
  });

  @override
  State<LuxuryBackground> createState() => _LuxuryBackgroundState();
}

class _LuxuryBackgroundState extends State<LuxuryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    if (widget.animateGlow) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundGradientStart,
            AppColors.background,
            AppColors.backgroundGradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Animated Ambient Soft Gold Circle (Top Right)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              final offsetX = math.sin(val * math.pi * 2) * 25.0;
              final offsetY = math.cos(val * math.pi * 2) * 20.0;

              return Positioned(
                top: -60 + offsetY,
                right: -70 + offsetX,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentGold.withOpacity(0.14),
                        AppColors.accentGoldLight.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Animated Ambient Rose/Burgundy Glow (Bottom Left)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              final offsetX = math.cos(val * math.pi * 2) * 20.0;
              final offsetY = math.sin(val * math.pi * 2) * 25.0;

              return Positioned(
                bottom: -80 + offsetY,
                left: -80 + offsetX,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.08),
                        AppColors.accentGold.withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Child content on top of ambient backdrop
          Positioned.fill(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
