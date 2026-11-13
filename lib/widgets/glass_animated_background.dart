import 'dart:ui';
import 'package:flutter/material.dart';

class GlassAnimatedBackground extends StatefulWidget {
  const GlassAnimatedBackground({super.key});

  @override
  State<GlassAnimatedBackground> createState() =>
      _GlassAnimatedBackgroundState();
}

class _GlassAnimatedBackgroundState extends State<GlassAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _blob({
    required double size,
    required List<Color> colors,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E7A3D),
                    Color(0xFF0A5D2E),
                    Color(0xFF159A4D),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40 + (30 * t),
              left: -40 + (20 * t),
              child: _blob(
                size: 180,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
            Positioned(
              top: 220 - (20 * t),
              right: -50 + (25 * t),
              child: _blob(
                size: 220,
                colors: [
                  const Color(0xFF7CFFD0).withOpacity(0.16),
                  const Color(0xFF7CFFD0).withOpacity(0.02),
                ],
              ),
            ),
            Positioned(
              bottom: 120 + (25 * t),
              left: 40 - (15 * t),
              child: _blob(
                size: 160,
                colors: [
                  const Color(0xFFB8FFF0).withOpacity(0.14),
                  const Color(0xFFB8FFF0).withOpacity(0.02),
                ],
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30 + (20 * t),
              child: _blob(
                size: 240,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.01),
                ],
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ],
        );
      },
    );
  }
}