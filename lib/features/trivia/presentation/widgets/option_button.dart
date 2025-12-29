import 'package:flutter/material.dart';

import '../../theme/trivia_colors.dart';
import '../../domain/entities/trivia_pokemon.dart';
import '../providers/trivia_provider.dart';

/// Botón estilizado para opciones de respuesta en el juego de trivia.
/// 
/// Cambia apariencia según el estado de la opción (normal, correcto, incorrecto, deshabilitado).
class OptionButton extends StatelessWidget {
  /// El Pokémon que representa esta opción
  final TriviaPokemon pokemon;
  
  /// Estado actual de la opción para estilo
  final OptionState state;
  
  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;
  
  /// Si el botón está habilitado
  final bool enabled;

  const OptionButton({
    super.key,
    required this.pokemon,
    required this.state,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        elevation: _getElevation(),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getBorderColor(),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state == OptionState.correct) ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                if (state == OptionState.wrong) ...[
                  const Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    pokemon.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case OptionState.normal:
        return TriviaColors.optionDefault;
      case OptionState.correct:
        return TriviaColors.correctAnswer;
      case OptionState.wrong:
        return TriviaColors.wrongAnswer;
      case OptionState.disabled:
        return TriviaColors.optionDisabled;
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case OptionState.normal:
        return TriviaColors.secondaryLight;
      case OptionState.correct:
        return TriviaColors.success;
      case OptionState.wrong:
        return TriviaColors.error;
      case OptionState.disabled:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    return Colors.white;
  }

  double _getElevation() {
    switch (state) {
      case OptionState.normal:
        return 4;
      case OptionState.correct:
      case OptionState.wrong:
        return 8;
      case OptionState.disabled:
        return 0;
    }
  }
}
