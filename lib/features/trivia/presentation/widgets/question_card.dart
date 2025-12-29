import 'package:flutter/material.dart';

import '../../theme/trivia_colors.dart';
import '../../domain/entities/question.dart';
import '../../domain/enums/question_type.dart';

/// Widget de tarjeta que muestra el contenido de la pregunta.
/// 
/// Para preguntas de silueta, muestra el texto de la pregunta.
/// Para preguntas de descripción, muestra la descripción del Pokémon.
class QuestionCard extends StatelessWidget {
  /// La pregunta a mostrar
  final Question question;

  const QuestionCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono del tipo de pregunta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TriviaColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getQuestionIcon(),
                color: TriviaColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            
            // Título de la pregunta
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: TriviaColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Descripción (solo para preguntas de tipo descripción)
            if (question.type == QuestionType.description) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TriviaColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TriviaColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  question.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: TriviaColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getQuestionIcon() {
    switch (question.type) {
      case QuestionType.silhouette:
        return Icons.visibility_off;
      case QuestionType.description:
        return Icons.description;
    }
  }
}
