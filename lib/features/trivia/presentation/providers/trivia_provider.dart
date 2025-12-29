import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/graphql/graphql_client_provider.dart';
import '../../domain/entities/trivia_pokemon.dart';
import '../../domain/entities/question.dart';
import '../../data/services/trivia_service.dart';
import '../../data/repositories/trivia_repository.dart';

// ==========================================
// Provider para el Idioma (Locale)
// ==========================================
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Idioma por defecto
    return const Locale('es');
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    state = state.languageCode == 'es'
        ? const Locale('en')
        : const Locale('es');
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

// ==========================================
// Estados y Lógica del Juego
// ==========================================

/// Enum que representa el estado actual del juego de trivia.
enum TriviaState {
  initial, loading, playing, answered, gameOver, error,
}

enum OptionState {
  normal, correct, wrong, disabled,
}

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

  OptionState getOptionState(TriviaPokemon option) {
    if (state != TriviaState.answered) return OptionState.normal;
    if (currentQuestion?.isCorrect(option) ?? false) return OptionState.correct;
    if (selectedAnswer?.id == option.id) return OptionState.wrong;
    return OptionState.disabled;
  }
}

// Providers de Dependencias
final triviaServiceProvider = Provider<TriviaService>((ref) {
  final clientNotifier = ref.watch(graphqlClientProvider);
  return TriviaService(clientNotifier.value);
});

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  final service = ref.watch(triviaServiceProvider);
  return TriviaRepository(service);
});

class TriviaNotifier extends Notifier<TriviaGameState> {
  @override
  TriviaGameState build() {
    return const TriviaGameState();
  }

  TriviaRepository get _repository => ref.read(triviaRepositoryProvider);

  Future<void> startGame() async {
    state = const TriviaGameState(
      state: TriviaState.loading,
      score: 0,
    );
    await _loadNextQuestion();
  }

  Future<void> _loadNextQuestion() async {
    state = state.copyWith(
      state: TriviaState.loading,
      selectedAnswer: null,
      wasAnswerCorrect: false,
      isRevealed: false,
    );

    try {
      // 1. LEER EL IDIOMA ACTUAL
      final currentLocale = ref.read(localeProvider);
      final languageCode = currentLocale.languageCode;

      // 2. PASARLO AL REPOSITORIO (CORRECCIÓN AQUÍ)
      // Antes no estabas pasando el parámetro, por eso siempre salía español.
      final question = await _repository.generateRandomQuestion(languageCode: languageCode);

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

  Future<void> submitAnswer(TriviaPokemon selectedPokemon) async {
    if (state.state != TriviaState.playing || state.currentQuestion == null) return;

    final isCorrect = state.currentQuestion!.isCorrect(selectedPokemon);

    state = state.copyWith(
      state: TriviaState.answered,
      selectedAnswer: selectedPokemon,
      wasAnswerCorrect: isCorrect,
      isRevealed: true,
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    if (isCorrect) {
      state = state.copyWith(score: state.score + 1);
      await _loadNextQuestion();
    } else {
      state = state.copyWith(state: TriviaState.gameOver);
    }
  }

  void resetGame() {
    state = const TriviaGameState();
  }

  Future<void> retryLoad() async {
    await _loadNextQuestion();
  }
}

final triviaProvider = NotifierProvider<TriviaNotifier, TriviaGameState>(
  TriviaNotifier.new,
);