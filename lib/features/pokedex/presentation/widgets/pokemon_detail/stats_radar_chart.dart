import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/config/app_constants.dart';
import '../../../domain/entities/pokemon_detail.dart';

/// Widget que muestra un gráfico de radar con las estadísticas del Pokémon
class StatsRadarChart extends StatelessWidget {
  const StatsRadarChart({
    super.key,
    required this.stats,
  });

  final List<PokemonStat> stats;

  // Valor máximo para las estadísticas (para escalar el gráfico)
  static const double maxStatValue = 255.0;

  // Orden de las estadísticas en el radar
  static const List<String> _statOrder = [
    'hp',
    'attack',
    'defense',
    'special-attack',
    'special-defense',
    'speed',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _RadarChartPainter(
          stats: _getOrderedStats(),
          statLabels: _getOrderedLabels(),
        ),
        size: const Size(220, 220),
      ),
    );
  }

  List<double> _getOrderedStats() {
    return _statOrder.map((statName) {
      final stat = stats.firstWhere(
        (s) => s.name == statName,
        orElse: () => PokemonStat(name: statName, baseStat: 0),
      );
      return (stat.baseStat / maxStatValue).clamp(0.0, 1.0);
    }).toList();
  }

  List<String> _getOrderedLabels() {
    return _statOrder.map((statName) {
      final stat = stats.firstWhere(
        (s) => s.name == statName,
        orElse: () => PokemonStat(name: statName, baseStat: 0),
      );
      final label = AppConstants.statNamesSpanish[statName] ?? statName;
      return '$label\n${stat.baseStat}';
    }).toList();
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.stats,
    required this.statLabels,
  });

  final List<double> stats;
  final List<String> statLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 35;
    final sides = stats.length;
    final angle = (2 * math.pi) / sides;

    // Dibujar los niveles del gráfico (círculos concéntricos)
    _drawLevels(canvas, center, radius, sides, angle);

    // Dibujar las líneas desde el centro
    _drawSpokes(canvas, center, radius, sides, angle);

    // Dibujar el polígono de estadísticas
    _drawStatsPolygon(canvas, center, radius, sides, angle);

    // Dibujar las etiquetas
    _drawLabels(canvas, center, radius, sides, angle);
  }

  void _drawLevels(Canvas canvas, Offset center, double radius, int sides, double angle) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final levelRadius = radius * (level / 4);
      final path = Path();

      for (int i = 0; i < sides; i++) {
        final x = center.dx + levelRadius * math.cos(angle * i - math.pi / 2);
        final y = center.dy + levelRadius * math.sin(angle * i - math.pi / 2);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawSpokes(Canvas canvas, Offset center, double radius, int sides, double angle) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  void _drawStatsPolygon(Canvas canvas, Offset center, double radius, int sides, double angle) {
    final fillPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    for (int i = 0; i < sides; i++) {
      final statRadius = radius * stats[i];
      final x = center.dx + statRadius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + statRadius * math.sin(angle * i - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Dibujar puntos en cada vértice
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sides; i++) {
      final statRadius = radius * stats[i];
      final x = center.dx + statRadius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + statRadius * math.sin(angle * i - math.pi / 2);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, int sides, double angle) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < sides; i++) {
      final labelRadius = radius + 25;
      final x = center.dx + labelRadius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + labelRadius * math.sin(angle * i - math.pi / 2);

      final textSpan = TextSpan(
        text: statLabels[i],
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      final textOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
