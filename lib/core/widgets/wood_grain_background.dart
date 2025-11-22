import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Un fondo decorativo de textura de madera para la UI de Pokédex
class WoodGrainBackground extends StatelessWidget {
  const WoodGrainBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: AppColors.woodBrown),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: CustomPaint(painter: _WoodGrainPainter()),
          ),
        ),
      ],
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    for (double x = -20; x < size.width + 20; x += 60) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..cubicTo(
            x + 15,
            size.height * 0.25,
            x - 10,
            size.height * 0.6,
            x + 10,
            size.height,
          )
          ..lineTo(x + 20, size.height)
          ..cubicTo(
            x + 35,
            size.height * 0.65,
            x + 10,
            size.height * 0.3,
            x + 30,
            0,
          ),
        paint..color = Colors.brown.shade300,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

