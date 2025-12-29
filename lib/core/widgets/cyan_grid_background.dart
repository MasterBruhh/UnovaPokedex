import 'package:flutter/material.dart';

/// Un fondo decorativo con patrón de cuadrícula estilo Pokédex con color cyan opaco
class CyanGridBackground extends StatelessWidget {
  const CyanGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFF4A8B8B)),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _CyanGridPainter()),
        ),
      ],
    );
  }
}

class _CyanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6AACAC).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const gridSize = 24.0;

    // Dibujar líneas verticales
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Dibujar líneas horizontales
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Agregar líneas diagonales alternadas para más detalle
    final diagonalPaint = Paint()
      ..color = const Color(0xFF6AACAC).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double x = 0; x <= size.width; x += gridSize * 2) {
      for (double y = 0; y <= size.height; y += gridSize * 2) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + gridSize, y + gridSize),
          diagonalPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
