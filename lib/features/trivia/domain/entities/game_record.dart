/// Representa un registro de partida para el ranking local.
class GameRecord {
  /// Puntuación obtenida
  final int score;
  
  /// Fecha de la partida
  final DateTime playedAt;
  
  /// Nombre del jugador (opcional)
  final String playerName;

  const GameRecord({
    required this.score,
    required this.playedAt,
    this.playerName = 'Player',
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'playedAt': playedAt.toIso8601String(),
    'playerName': playerName,
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
    score: json['score'] as int,
    playedAt: DateTime.parse(json['playedAt'] as String),
    playerName: json['playerName'] as String? ?? 'Player',
  );

  @override
  String toString() => 'GameRecord(score: $score, playedAt: $playedAt)';
}
