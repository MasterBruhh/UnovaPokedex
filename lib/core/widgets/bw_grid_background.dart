import 'package:flutter/material.dart';

/// Un fondo decorativo con patrón de cuadrícula estilo Pokémon Blanco/Negro
class BWGridBackground extends StatelessWidget {
  const BWGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: CustomPaint(
        painter: _BWGridPainter(),
        child: Container(),
      ),
    );
  }
}

class _BWGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const squareSize = 20.0;

    // Dibujar cuadrados blancos alternados
    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final row = (y / squareSize).floor();
        final col = (x / squareSize).floor();
        
        if ((row + col) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, squareSize, squareSize),
            paint,
          );
        }
      }
    }

    // Dibujar líneas de cuadrícula
    for (double x = 0; x <= size.width; x += squareSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }

    for (double y = 0; y <= size.height; y += squareSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
