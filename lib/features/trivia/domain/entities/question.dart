import 'trivia_pokemon.dart';
import '../enums/question_type.dart';

/// Entidad que representa una pregunta de trivia.
/// 
/// Contiene todos los datos necesarios para mostrar una pregunta,
/// incluyendo la respuesta correcta, opciones y tipo de pregunta.
class Question {
  /// El Pokémon de respuesta correcta
  final TriviaPokemon correctPokemon;
  
  /// Lista de todas las opciones (incluyendo la respuesta correcta)
  final List<TriviaPokemon> options;
  
  /// El tipo de pregunta (silhouette o description)
  final QuestionType type;

  const Question({
    required this.correctPokemon,
    required this.options,
    required this.type,
  });

  /// Retorna el texto de la pregunta según el tipo
  String get questionText {
    switch (type) {
      case QuestionType.silhouette:
        return "Who's that Pokémon?";
      case QuestionType.description:
        return "Which Pokémon matches this description?";
    }
  }

  /// Retorna la descripción para preguntas de tipo descripción
  String get description {
    if (type == QuestionType.description) {
      return correctPokemon.cleanDescription;
    }
    return '';
  }

  /// Retorna la URL del sprite para preguntas de tipo silueta
  String get spriteUrl {
    return correctPokemon.spriteUrl;
  }

  /// Verifica si la opción seleccionada es correcta
  bool isCorrect(TriviaPokemon selectedOption) {
    return selectedOption.id == correctPokemon.id;
  }

  /// Verifica si el ID de la opción seleccionada es correcto
  bool isCorrectById(int selectedId) {
    return selectedId == correctPokemon.id;
  }

  @override
  String toString() => 'Question(type: $type, correct: ${correctPokemon.name})';
}
