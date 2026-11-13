import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBackground extends StatefulWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 84, 189, 87),
                const Color.fromARGB(255, 59, 145, 137),
                const Color.fromARGB(255, 144, 238, 144),
              ],
              begin: Alignment(-1 + controller.value, -1),
              end: Alignment(1, 1),
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              color: Colors.white.withOpacity(0.08),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}