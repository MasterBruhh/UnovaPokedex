import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/graphql/graphql_client_provider.dart';
import '../../domain/entities/trivia_pokemon.dart';
import '../../domain/entities/question.dart';
import '../../data/services/trivia_service.dart';
import '../../data/repositories/trivia_repository.dart';

/// Enum que representa el estado actual del juego de trivia.
enum TriviaState {
  /// Estado inicial antes de que comience el juego
  initial,
  
  /// Cargando una nueva pregunta
  loading,
  
  /// Pregunta lista y esperando input del usuario
  playing,
  
  /// Usuario seleccionó una respuesta, mostrando resultado
  answered,
  
  /// Juego terminado (respuesta incorrecta seleccionada)
  gameOver,
  
  /// Ocurrió un error
  error,
}

/// Enum para estados visuales de los botones de opción.
enum OptionState {
  normal,
  correct,
  wrong,
  disabled,
}

/// Modelo de estado para el juego de trivia.
class TriviaGameState {
  final TriviaState state;
  final Question? currentQuestion;
  final int score;
  final TriviaPokemon? selectedAnswer;
  final bool wasAnswerCorrect;
  final bool isRevealed;
  final String errorMessage;

  const TriviaGameState({
    this.state = TriviaState.initial,
    this.currentQuestion,
    this.score = 0,
    this.selectedAnswer,
    this.wasAnswerCorrect = false,
    this.isRevealed = false,
    this.errorMessage = '',
  });

  TriviaGameState copyWith({
    TriviaState? state,
    Question? currentQuestion,
    int? score,
    TriviaPokemon? selectedAnswer,
    bool? wasAnswerCorrect,
    bool? isRevealed,
    String? errorMessage,
  }) {
    return TriviaGameState(
      state: state ?? this.state,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      score: score ?? this.score,
      selectedAnswer: selectedAnswer,
      wasAnswerCorrect: wasAnswerCorrect ?? this.wasAnswerCorrect,
      isRevealed: isRevealed ?? this.isRevealed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Obtiene el estado de una opción específica para propósitos de estilo.
  OptionState getOptionState(TriviaPokemon option) {
    if (state != TriviaState.answered) {
      return OptionState.normal;
    }

    if (currentQuestion?.isCorrect(option) ?? false) {
      return OptionState.correct;
    }

    if (selectedAnswer?.id == option.id) {
      return OptionState.wrong;
    }

    return OptionState.disabled;
  }
}

/// Provider para el servicio de trivia.
final triviaServiceProvider = Provider<TriviaService>((ref) {
  final clientNotifier = ref.watch(graphqlClientProvider);
  return TriviaService(clientNotifier.value);
});

/// Provider para el repositorio de trivia.
final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  final service = ref.watch(triviaServiceProvider);
  return TriviaRepository(service);
});

/// Notifier para gestionar el estado del juego de trivia.
class TriviaNotifier extends Notifier<TriviaGameState> {
  @override
  TriviaGameState build() {
    return const TriviaGameState();
  }

  TriviaRepository get _repository => ref.read(triviaRepositoryProvider);

  /// Inicia un nuevo juego, reiniciando puntuación y cargando primera pregunta.
  Future<void> startGame() async {
    state = const TriviaGameState(
      state: TriviaState.loading,
      score: 0,
    );
    await _loadNextQuestion();
  }

  /// Carga la siguiente pregunta.
  Future<void> _loadNextQuestion() async {
    state = state.copyWith(
      state: TriviaState.loading,
      selectedAnswer: null,
      wasAnswerCorrect: false,
      isRevealed: false,
    );

    try {
      final question = await _repository.generateRandomQuestion();
      state = state.copyWith(
        state: TriviaState.playing,
        currentQuestion: question,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        state: TriviaState.error,
        errorMessage: 'Error al cargar pregunta: ${e.toString()}',
      );
    }
  }

  /// Envía una respuesta para la pregunta actual.
  Future<void> submitAnswer(TriviaPokemon selectedPokemon) async {
    if (state.state != TriviaState.playing || state.currentQuestion == null) {
      return;
    }

    final isCorrect = state.currentQuestion!.isCorrect(selectedPokemon);
    
    state = state.copyWith(
      state: TriviaState.answered,
      selectedAnswer: selectedPokemon,
      wasAnswerCorrect: isCorrect,
      isRevealed: true,
    );

    // Esperar para la animación de revelación
    await Future.delayed(const Duration(milliseconds: 1500));

    if (isCorrect) {
      state = state.copyWith(score: state.score + 1);
      await _loadNextQuestion();
    } else {
      state = state.copyWith(state: TriviaState.gameOver);
    }
  }

  /// Reinicia el juego al estado inicial.
  void resetGame() {
    state = const TriviaGameState();
  }

  /// Reintenta cargar la pregunta actual después de un error.
  Future<void> retryLoad() async {
    await _loadNextQuestion();
  }
}

/// Provider principal para el estado del juego de trivia.
final triviaProvider = NotifierProvider<TriviaNotifier, TriviaGameState>(
  TriviaNotifier.new,
);
