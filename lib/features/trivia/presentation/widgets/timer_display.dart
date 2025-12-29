import 'package:flutter/material.dart';

import '../../theme/trivia_colors.dart';
import '../providers/trivia_provider.dart';

/// Widget que muestra el temporizador con barra de progreso animada.
class TimerDisplay extends StatelessWidget {
  /// Segundos restantes
  final int timeRemaining;
  
  /// Tiempo total por pregunta
  final int totalTime;

  const TimerDisplay({
    super.key,
    required this.timeRemaining,
    this.totalTime = TriviaConstants.timePerQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final progress = timeRemaining / totalTime;
    final isLowTime = timeRemaining <= 5;
    
    return Semantics(
      label: '$timeRemaining segundos restantes',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de reloj animado
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isLowTime ? Icons.timer_off : Icons.timer,
                key: ValueKey(isLowTime),
                color: isLowTime ? TriviaColors.error : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            // Tiempo
            SizedBox(
              width: 30,
              child: Text(
                '$timeRemaining',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLowTime ? TriviaColors.error : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            // Barra de progreso
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLowTime ? TriviaColors.error : TriviaColors.success,
                  ),
                  minHeight: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra de progreso circular para el timer
class CircularTimerDisplay extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;

  const CircularTimerDisplay({
    super.key,
    required this.timeRemaining,
    this.totalTime = TriviaConstants.timePerQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final progress = timeRemaining / totalTime;
    final isLowTime = timeRemaining <= 5;

    return Semantics(
      label: '$timeRemaining segundos restantes',
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLowTime ? TriviaColors.error : TriviaColors.accent,
              ),
            ),
          ),
          Text(
            '$timeRemaining',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLowTime ? TriviaColors.error : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
