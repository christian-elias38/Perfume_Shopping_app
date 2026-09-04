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
    18,
    (index) => _Particle(
      x: math.Random().nextDouble(),
      y: math.Random().nextDouble(),
      size: math.Random().nextDouble() * 4 + 2,
      speed: math.Random().nextDouble() * 0.0008 + 0.0003,
      opacity: math.Random().nextDouble() * 0.4 + 0.1,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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
    final bgColor1 = widget.isDarkMode ? const Color(0xFF140D0F) : AppColors.backgroundGradientStart;
    final bgColor2 = widget.isDarkMode ? const Color(0xFF1E1317) : AppColors.background;
    final bgColor3 = widget.isDarkMode ? const Color(0xFF0F0A0B) : AppColors.backgroundGradientEnd;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor1, bgColor2, bgColor3],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Ambient Glow Orb 1: Champagne Gold (Top Right)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              final offsetX = math.sin(val * math.pi * 2) * 35.0;
              final offsetY = math.cos(val * math.pi * 2) * 30.0;

              return Positioned(
                top: -80 + offsetY,
                right: -90 + offsetX,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentGold.withOpacity(0.18),
                        AppColors.accentGoldLight.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Ambient Glow Orb 2: Deep Burgundy Rose (Bottom Left)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              final offsetX = math.cos(val * math.pi * 2) * 30.0;
              final offsetY = math.sin(val * math.pi * 2) * 35.0;

              return Positioned(
                bottom: -90 + offsetY,
                left: -90 + offsetX,
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.12),
                        AppColors.accentGold.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Ambient Glow Orb 3: Soft Amber Center Pulse
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              final pulseScale = 1.0 + math.sin(val * math.pi) * 0.15;

              return Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: MediaQuery.of(context).size.width * 0.2,
                child: Transform.scale(
                  scale: pulseScale,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentGold.withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Floating Scent Mist Particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final size = MediaQuery.of(context).size;
              return CustomPaint(
                size: size,
                painter: _MistParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                  isDark: widget.isDarkMode,
                ),
              );
            },
          ),

          // Main Screen Content
          Positioned.fill(
            child: widget.child,
          ),
        ],
      ),
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
