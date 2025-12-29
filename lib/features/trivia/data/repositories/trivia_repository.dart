import 'dart:math';

import '../../../../core/config/app_constants.dart';
import '../../domain/entities/trivia_pokemon.dart';
import '../../domain/entities/question.dart';
import '../../domain/enums/question_type.dart';
import '../services/trivia_service.dart';

class TriviaRepository {
  final TriviaService _service;
  final Random _random = Random();

  TriviaRepository(this._service);

  /// Genera una pregunta aleatoria.
  /// CAMBIO 1: Recibe el languageCode (por defecto 'es')
  Future<Question> generateRandomQuestion({String languageCode = 'es'}) async {
    final questionType = _getRandomQuestionType();

    // CAMBIO 2: Si el tipo es descripción, delegamos al método específico
    // pasando el idioma. Esto asegura que se busque la descripción traducida.
    if (questionType == QuestionType.description) {
      return generateDescriptionQuestion(languageCode: languageCode);
    }

    // Si es silueta, usamos la lógica estándar (el idioma no afecta la imagen)
    return generateSilhouetteQuestion();
  }

  Future<Question> generateSilhouetteQuestion() async {
    final correctPokemonId = _getRandomPokemonId();
    final correctPokemon = await _service.fetchPokemonById(correctPokemonId);
    final wrongOptionIds = _generateWrongOptionIds(correctPokemonId, 3);
    final wrongOptions = await _service.fetchPokemonByIds(wrongOptionIds);

    final allOptions = [correctPokemon, ...wrongOptions];
    allOptions.shuffle(_random);

    return Question(
      correctPokemon: correctPokemon,
      options: allOptions,
      type: QuestionType.silhouette,
    );
  }

  /// Genera una pregunta de tipo descripción.
  /// CAMBIO 3: Recibe el languageCode
  Future<Question> generateDescriptionQuestion({String languageCode = 'es'}) async {
    final correctPokemonId = _getRandomPokemonId();

    // CAMBIO 4: Pasamos el languageCode al servicio
    // NOTA: Esto marcará error hasta que actualicemos trivia_service.dart
    final correctPokemon = await _service.fetchPokemonWithDescription(
        correctPokemonId,
        languageCode: languageCode
    );

    // Asegurar que tenemos una descripción válida
    if (correctPokemon.cleanDescription.isEmpty) {
      for (int i = 0; i < 5; i++) {
        final retryId = _getRandomPokemonId();
        // CAMBIO 5: También en los reintentos
        final retryPokemon = await _service.fetchPokemonWithDescription(
            retryId,
            languageCode: languageCode
        );

        if (retryPokemon.cleanDescription.isNotEmpty) {
          return _buildDescriptionQuestion(retryPokemon);
        }
      }
      // Fallback a silueta
      return generateSilhouetteQuestion();
    }

    return _buildDescriptionQuestion(correctPokemon);
  }

  Future<Question> _buildDescriptionQuestion(TriviaPokemon correctPokemon) async {
    final wrongOptionIds = _generateWrongOptionIds(correctPokemon.id, 3);
    final wrongOptions = await _service.fetchPokemonByIds(wrongOptionIds);

    final allOptions = [correctPokemon, ...wrongOptions];
    allOptions.shuffle(_random);

    return Question(
      correctPokemon: correctPokemon,
      options: allOptions,
      type: QuestionType.description,
    );
  }

  QuestionType _getRandomQuestionType() {
    return _random.nextBool() ? QuestionType.silhouette : QuestionType.description;
  }

  int _getRandomPokemonId() {
    return _random.nextInt(AppConstants.maxPokemonId) + 1;
  }

  List<int> _generateWrongOptionIds(int correctId, int count) {
    final Set<int> wrongIds = {};

    while (wrongIds.length < count) {
      final randomId = _getRandomPokemonId();
      if (randomId != correctId && !wrongIds.contains(randomId)) {
        wrongIds.add(randomId);
      }
    }

    return wrongIds.toList();
  }
}