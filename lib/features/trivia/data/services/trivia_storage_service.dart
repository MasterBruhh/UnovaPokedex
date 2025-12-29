import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/entities/game_record.dart';

/// Servicio de almacenamiento local para datos de trivia.
/// 
/// Usa Hive para persistir:
/// - Ranking de mejores puntajes
/// - Logros desbloqueados
/// - Estadísticas del jugador
class TriviaStorageService {
  static const String _boxName = 'trivia_storage';
  static const String _rankingKey = 'ranking';
  static const String _achievementsKey = 'achievements';
  static const String _totalGamesKey = 'total_games';
  static const String _bestScoreKey = 'best_score';

  Box? _box;

  /// Inicializa el servicio de almacenamiento
  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
  }

  /// Asegura que el box esté abierto
  Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  // ==========================================
  // Ranking
  // ==========================================

  /// Guarda un nuevo registro de partida
  Future<void> saveGameRecord(GameRecord record) async {
    final box = await _getBox();
    
    // Obtener ranking actual
    final ranking = await getRanking();
    ranking.add(record);
    
    // Ordenar por puntuación descendente
    ranking.sort((a, b) => b.score.compareTo(a.score));
    
    // Mantener solo top 10
    final top10 = ranking.take(10).toList();
    
    // Guardar
    final jsonList = top10.map((r) => r.toJson()).toList();
    await box.put(_rankingKey, jsonEncode(jsonList));
    
    // Actualizar estadísticas
    await _incrementTotalGames();
    await _updateBestScore(record.score);
  }

  /// Obtiene el ranking de mejores puntajes
  Future<List<GameRecord>> getRanking() async {
    final box = await _getBox();
    final jsonString = box.get(_rankingKey) as String?;
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => GameRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Obtiene el mejor puntaje histórico
  Future<int> getBestScore() async {
    final box = await _getBox();
    return box.get(_bestScoreKey, defaultValue: 0) as int;
  }

  Future<void> _updateBestScore(int score) async {
    final box = await _getBox();
    final currentBest = box.get(_bestScoreKey, defaultValue: 0) as int;
    if (score > currentBest) {
      await box.put(_bestScoreKey, score);
    }
  }

  /// Obtiene el total de partidas jugadas
  Future<int> getTotalGames() async {
    final box = await _getBox();
    return box.get(_totalGamesKey, defaultValue: 0) as int;
  }

  Future<void> _incrementTotalGames() async {
    final box = await _getBox();
    final current = box.get(_totalGamesKey, defaultValue: 0) as int;
    await box.put(_totalGamesKey, current + 1);
  }

  // ==========================================
  // Logros
  // ==========================================

  /// Obtiene todos los logros con su estado actual
  Future<List<Achievement>> getAchievements() async {
    final box = await _getBox();
    final jsonString = box.get(_achievementsKey) as String?;
    
    // Obtener logros guardados
    Map<String, Achievement> savedAchievements = {};
    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List;
        for (final json in jsonList) {
          final achievement = Achievement.fromJson(json as Map<String, dynamic>);
          savedAchievements[achievement.id] = achievement;
        }
      } catch (_) {
        // Ignorar errores de parseo
      }
    }
    
    // Combinar con lista completa de logros
    return Achievement.allAchievements.map((baseAchievement) {
      final saved = savedAchievements[baseAchievement.id];
      if (saved != null && saved.isUnlocked) {
        return baseAchievement.copyWith(
          isUnlocked: true,
          unlockedAt: saved.unlockedAt,
        );
      }
      return baseAchievement;
    }).toList();
  }

  /// Desbloquea logros basándose en el puntaje
  Future<List<Achievement>> unlockAchievements(int score) async {
    final box = await _getBox();
    final achievements = await getAchievements();
    final newlyUnlocked = <Achievement>[];
    
    final updatedAchievements = achievements.map((achievement) {
      // Si ya está desbloqueado, mantenerlo
      if (achievement.isUnlocked) return achievement;
      
      // Verificar si se cumple el requisito
      bool shouldUnlock = false;
      
      if (achievement.id == 'first_game') {
        // Se desbloquea al jugar la primera partida
        shouldUnlock = true;
      } else if (score >= achievement.requiredScore) {
        shouldUnlock = true;
      }
      
      if (shouldUnlock) {
        final unlocked = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        newlyUnlocked.add(unlocked);
        return unlocked;
      }
      
      return achievement;
    }).toList();
    
    // Guardar logros actualizados
    final jsonList = updatedAchievements.map((a) => a.toJson()).toList();
    await box.put(_achievementsKey, jsonEncode(jsonList));
    
    return newlyUnlocked;
  }

  /// Obtiene el número de logros desbloqueados
  Future<int> getUnlockedAchievementsCount() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.isUnlocked).length;
  }

  // ==========================================
  // Reset
  // ==========================================

  /// Limpia todos los datos de trivia
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
