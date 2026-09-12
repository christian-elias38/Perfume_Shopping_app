import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LuxuryBackground extends StatefulWidget {
  final Widget child;
  final bool animateGlow;
  final bool isDarkMode;

  const LuxuryBackground({
    super.key,
    required this.child,
    this.animateGlow = true,
    this.isDarkMode = false,
  });

  @override
  State<LuxuryBackground> createState() => _LuxuryBackgroundState();
}

class _LuxuryBackgroundState extends State<LuxuryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = List.generate(
    22,
    (index) => _Particle(
      x: math.Random().nextDouble(),
      y: math.Random().nextDouble(),
      size: math.Random().nextDouble() * 4 + 2,
      speed: math.Random().nextDouble() * 0.0008 + 0.0003,
      opacity: math.Random().nextDouble() * 0.45 + 0.15,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final val = _controller.value;
        final angle = val * math.pi * 2;

        // Dynamic Animated Gradient Colors
        final grad1 = Color.lerp(
          widget.isDarkMode ? const Color(0xFF140D0F) : AppColors.backgroundGradientStart,
          widget.isDarkMode ? const Color(0xFF1C0A10) : const Color(0xFFFDF7F0),
          math.sin(angle) * 0.5 + 0.5,
        )!;

        final grad2 = Color.lerp(
          widget.isDarkMode ? const Color(0xFF1E1317) : AppColors.background,
          widget.isDarkMode ? const Color(0xFF28151D) : const Color(0xFFF6ECE0),
          math.cos(angle) * 0.5 + 0.5,
        )!;

        final grad3 = Color.lerp(
          widget.isDarkMode ? const Color(0xFF0F0A0B) : AppColors.backgroundGradientEnd,
          widget.isDarkMode ? const Color(0xFF180A0E) : const Color(0xFFEEE1D2),
          math.sin(angle * 0.5) * 0.5 + 0.5,
        )!;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [grad1, grad2, grad3],
              begin: Alignment(math.sin(angle * 0.5), -1.0),
              end: Alignment(-math.sin(angle * 0.5), 1.0),
            ),
          ),
          child: Stack(
            children: [
              // Ambient Glow Orb 1: Champagne Gold (Top Right)
              Positioned(
                top: -90 + math.cos(angle) * 35.0,
                right: -100 + math.sin(angle) * 40.0,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentGold.withOpacity(0.22),
                        AppColors.accentGoldLight.withOpacity(0.09),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Ambient Glow Orb 2: Deep Burgundy Rose (Bottom Left)
              Positioned(
                bottom: -100 + math.sin(angle) * 35.0,
                left: -100 + math.cos(angle) * 40.0,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.16),
                        AppColors.accentGold.withOpacity(0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Ambient Glow Orb 3: Soft Amber Center Pulse
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                left: MediaQuery.of(context).size.width * 0.15,
                child: Transform.scale(
                  scale: 1.0 + math.sin(val * math.pi) * 0.18,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentGold.withOpacity(0.08),
                          AppColors.primary.withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Scent Mist Particles
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _MistParticlePainter(
                  particles: _particles,
                  progress: val,
                  isDark: widget.isDarkMode,
                ),
              ),

              // Main Content Overlay
              Positioned.fill(
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _MistParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isDark;

  _MistParticlePainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final curY = (p.y - progress * p.speed * 50) % 1.0;
      final curX = (p.x + math.sin(progress * math.pi * 2 + p.y * 10) * 0.02) % 1.0;

      final posX = curX * size.width;
      final posY = curY * size.height;

      paint.color = (isDark ? AppColors.accentGold : AppColors.accentGold)
          .withOpacity(p.opacity * (0.6 + 0.4 * math.sin(progress * math.pi * 2 + p.x * 5)));

      canvas.drawCircle(Offset(posX, posY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MistParticlePainter oldDelegate) => true;
}
