import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/graphql/graphql_client_provider.dart';
import '../../domain/entities/trivia_pokemon.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/game_record.dart';
import '../../data/services/trivia_service.dart';
import '../../data/services/trivia_storage_service.dart';
import '../../data/repositories/trivia_repository.dart';

// ==========================================
// Provider para el Idioma (Locale)
// ==========================================
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
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
// Constantes del juego
// ==========================================
class TriviaConstants {
  static const int timePerQuestion = 15; // segundos
  static const int pointsPerCorrectAnswer = 1;
}

// ==========================================
// Estados y Lógica del Juego
// ==========================================

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
  final int timeRemaining;
  final int questionsAnswered;
  final List<Achievement> newlyUnlockedAchievements;

  const TriviaGameState({
    this.state = TriviaState.initial,
    this.currentQuestion,
    this.score = 0,
    this.selectedAnswer,
    this.wasAnswerCorrect = false,
    this.isRevealed = false,
    this.errorMessage = '',
    this.timeRemaining = TriviaConstants.timePerQuestion,
    this.questionsAnswered = 0,
    this.newlyUnlockedAchievements = const [],
  });

  TriviaGameState copyWith({
    TriviaState? state,
    Question? currentQuestion,
    int? score,
    TriviaPokemon? selectedAnswer,
    bool? wasAnswerCorrect,
    bool? isRevealed,
    String? errorMessage,
    int? timeRemaining,
    int? questionsAnswered,
    List<Achievement>? newlyUnlockedAchievements,
  }) {
    return TriviaGameState(
      state: state ?? this.state,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      score: score ?? this.score,
      selectedAnswer: selectedAnswer,
      wasAnswerCorrect: wasAnswerCorrect ?? this.wasAnswerCorrect,
      isRevealed: isRevealed ?? this.isRevealed,
      errorMessage: errorMessage ?? this.errorMessage,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      newlyUnlockedAchievements: newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
    );
  }

  OptionState getOptionState(TriviaPokemon option) {
    if (state != TriviaState.answered) return OptionState.normal;
    if (currentQuestion?.isCorrect(option) ?? false) return OptionState.correct;
    if (selectedAnswer?.id == option.id) return OptionState.wrong;
    return OptionState.disabled;
  }

  /// Porcentaje de tiempo restante (0.0 a 1.0)
  double get timeProgress => timeRemaining / TriviaConstants.timePerQuestion;
}

// ==========================================
// Providers de Dependencias
// ==========================================
final triviaServiceProvider = Provider<TriviaService>((ref) {
  final clientNotifier = ref.watch(graphqlClientProvider);
  return TriviaService(clientNotifier.value);
});

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  final service = ref.watch(triviaServiceProvider);
  return TriviaRepository(service);
});

final triviaStorageProvider = Provider<TriviaStorageService>((ref) {
  return TriviaStorageService();
});

// ==========================================
// Provider para Ranking
// ==========================================
final rankingProvider = FutureProvider<List<GameRecord>>((ref) async {
  final storage = ref.read(triviaStorageProvider);
  await storage.init();
  return storage.getRanking();
});

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final storage = ref.read(triviaStorageProvider);
  await storage.init();
  return storage.getAchievements();
});

final bestScoreProvider = FutureProvider<int>((ref) async {
  final storage = ref.read(triviaStorageProvider);
  await storage.init();
  return storage.getBestScore();
});

// ==========================================
// Notifier Principal del Juego
// ==========================================
class TriviaNotifier extends Notifier<TriviaGameState> {
  Timer? _timer;

  @override
  TriviaGameState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const TriviaGameState();
  }

  TriviaRepository get _repository => ref.read(triviaRepositoryProvider);
  TriviaStorageService get _storage => ref.read(triviaStorageProvider);

  Future<void> startGame() async {
    _timer?.cancel();
    await _storage.init();
    
    state = const TriviaGameState(
      state: TriviaState.loading,
      score: 0,
      questionsAnswered: 0,
    );
    await _loadNextQuestion();
  }

  Future<void> _loadNextQuestion() async {
    _timer?.cancel();
    
    state = state.copyWith(
      state: TriviaState.loading,
      selectedAnswer: null,
      wasAnswerCorrect: false,
      isRevealed: false,
      timeRemaining: TriviaConstants.timePerQuestion,
      newlyUnlockedAchievements: [],
    );

    try {
      final currentLocale = ref.read(localeProvider);
      final languageCode = currentLocale.languageCode;
      final question = await _repository.generateRandomQuestion(languageCode: languageCode);

      state = state.copyWith(
        state: TriviaState.playing,
        currentQuestion: question,
        errorMessage: '',
      );
      
      _startTimer();
    } catch (e) {
      state = state.copyWith(
        state: TriviaState.error,
        errorMessage: 'Error al cargar pregunta: ${e.toString()}',
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.state != TriviaState.playing) {
        timer.cancel();
        return;
      }

      final newTime = state.timeRemaining - 1;
      
      if (newTime <= 0) {
        timer.cancel();
        _handleTimeUp();
      } else {
        state = state.copyWith(timeRemaining: newTime);
      }
    });
  }

  void _handleTimeUp() {
    state = state.copyWith(
      state: TriviaState.answered,
      wasAnswerCorrect: false,
      isRevealed: true,
      timeRemaining: 0,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      _endGame();
    });
  }

  Future<void> submitAnswer(TriviaPokemon selectedPokemon) async {
    if (state.state != TriviaState.playing || state.currentQuestion == null) return;

    _timer?.cancel();
    
    final isCorrect = state.currentQuestion!.isCorrect(selectedPokemon);

    state = state.copyWith(
      state: TriviaState.answered,
      selectedAnswer: selectedPokemon,
      wasAnswerCorrect: isCorrect,
      isRevealed: true,
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    if (isCorrect) {
      final basePoints = TriviaConstants.pointsPerCorrectAnswer;
      final newScore = state.score + basePoints;
      
      state = state.copyWith(
        score: newScore,
        questionsAnswered: state.questionsAnswered + 1,
      );
      await _loadNextQuestion();
    } else {
      await _endGame();
    }
  }

  Future<void> _endGame() async {
    final finalScore = state.score;
    
    final record = GameRecord(
      score: finalScore,
      playedAt: DateTime.now(),
    );
    await _storage.saveGameRecord(record);
    
    final newAchievements = await _storage.unlockAchievements(finalScore);
    
    ref.invalidate(rankingProvider);
    ref.invalidate(achievementsProvider);
    ref.invalidate(bestScoreProvider);
    
    state = state.copyWith(
      state: TriviaState.gameOver,
      newlyUnlockedAchievements: newAchievements,
    );
  }

  void resetGame() {
    _timer?.cancel();
    state = const TriviaGameState();
  }

  Future<void> retryLoad() async {
    await _loadNextQuestion();
  }

  void clearNewAchievements() {
    state = state.copyWith(newlyUnlockedAchievements: []);
  }
}

final triviaProvider = NotifierProvider<TriviaNotifier, TriviaGameState>(
  TriviaNotifier.new,
);