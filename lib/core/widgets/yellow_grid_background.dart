import 'package:flutter/material.dart';

/// Fondo con patrón de cuadrícula amarilla oscura para la sección de Trivia
class YellowGridBackground extends StatelessWidget {
  const YellowGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF8B7500), // Amarillo oscuro/dorado oscuro opaco
      child: CustomPaint(
        painter: _YellowGridPainter(),
        child: Container(),
      ),
    );
  }
}

class _YellowGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1.5;

    const gridSize = 24.0;

    // Líneas verticales
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Líneas horizontales
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Líneas diagonales ocasionales para textura
    final accentPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += gridSize * 4) {
      for (double y = 0; y < size.height; y += gridSize * 4) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + gridSize * 2, y + gridSize * 2),
          accentPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
