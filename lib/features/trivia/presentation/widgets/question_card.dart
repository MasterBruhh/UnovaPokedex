import 'package:flutter/material.dart';
// 1. IMPORTAR L10N
import 'package:pokedex/l10n/app_localizations.dart';

import '../../theme/trivia_colors.dart';
import '../../domain/entities/question.dart';
import '../../domain/enums/question_type.dart';

class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    // 2. OBTENER TRADUCCIONES
    final l10n = AppLocalizations.of(context)!;

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

            // 3. CAMBIO AQUÍ: Usar traducción en lugar de texto fijo
            Text(
              _getLocalizedTitle(l10n), // Usamos función auxiliar
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: TriviaColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

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
                  question.description, // Esta descripción sí viene de la API/Repository
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

  // 4. FUNCIÓN PARA OBTENER TÍTULO TRADUCIDO
  String _getLocalizedTitle(AppLocalizations l10n) {
    switch (question.type) {
      case QuestionType.silhouette:
        return l10n.modeSilhouetteTitle; // "¿Quién es ese Pokémon?"
      case QuestionType.description:
        return l10n.modeDescriptionTitle; // "Desafío de descripción"
    }
  }
}