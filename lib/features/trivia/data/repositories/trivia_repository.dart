import 'dart:math';

import '../../../../core/config/app_constants.dart';
import '../../domain/entities/trivia_pokemon.dart';
import '../../domain/entities/question.dart';
import '../../domain/enums/question_type.dart';
import '../services/trivia_service.dart';

/// Repositorio para gestionar datos y lógica del juego de trivia.
/// 
/// Este repositorio es responsable de generar preguntas aleatorias,
/// gestionar opciones de respuesta y coordinar con TriviaService.
class TriviaRepository {
  final TriviaService _service;
  final Random _random = Random();

  TriviaRepository(this._service);

  /// Genera una pregunta de trivia aleatoria.
  /// 
  /// El tipo de pregunta se selecciona aleatoriamente entre silueta y descripción.
  /// Retorna una [Question] con el Pokémon correcto y 4 opciones mezcladas.
  Future<Question> generateRandomQuestion() async {
    // Seleccionar tipo de pregunta aleatoriamente
    final questionType = _getRandomQuestionType();
    
    // Obtener un ID de Pokémon aleatorio para la respuesta correcta
    final correctPokemonId = _getRandomPokemonId();
    
    // Obtener el Pokémon correcto con detalles completos
    final correctPokemon = await _service.fetchPokemonById(correctPokemonId);
    
    // Generar 3 opciones incorrectas aleatorias (diferentes a la correcta)
    final wrongOptionIds = _generateWrongOptionIds(correctPokemonId, 3);
    
    // Obtener opciones incorrectas
    final wrongOptions = await _service.fetchPokemonByIds(wrongOptionIds);
    
    // Combinar y mezclar todas las opciones
    final allOptions = [correctPokemon, ...wrongOptions];
    allOptions.shuffle(_random);
    
    return Question(
      correctPokemon: correctPokemon,
      options: allOptions,
      type: questionType,
    );
  }

  /// Genera una pregunta de tipo silueta.
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
  Future<Question> generateDescriptionQuestion() async {
    final correctPokemonId = _getRandomPokemonId();
    final correctPokemon = await _service.fetchPokemonWithDescription(correctPokemonId);
    
    // Asegurar que tenemos una descripción válida, reintentar si no
    if (correctPokemon.cleanDescription.isEmpty) {
      // Intentar algunas veces más para obtener un Pokémon con descripción
      for (int i = 0; i < 5; i++) {
        final retryId = _getRandomPokemonId();
        final retryPokemon = await _service.fetchPokemonWithDescription(retryId);
        if (retryPokemon.cleanDescription.isNotEmpty) {
          return _buildDescriptionQuestion(retryPokemon);
        }
      }
      // Fallback a silueta si no se encuentra descripción
      return generateSilhouetteQuestion();
    }
    
    return _buildDescriptionQuestion(correctPokemon);
  }

  /// Helper para construir una pregunta de descripción.
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

  /// Retorna un QuestionType aleatorio.
  QuestionType _getRandomQuestionType() {
    return _random.nextBool() ? QuestionType.silhouette : QuestionType.description;
  }

  /// Genera un ID de Pokémon aleatorio dentro del rango válido.
  int _getRandomPokemonId() {
    // Usar rango de 1 a maxPokemonId (1025 en el proyecto principal)
    return _random.nextInt(AppConstants.maxPokemonId) + 1;
  }

  /// Genera una lista de IDs de opciones incorrectas aleatorias.
  /// 
  /// Asegura que no haya duplicados y excluye la respuesta correcta.
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
