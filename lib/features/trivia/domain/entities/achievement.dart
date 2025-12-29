/// Representa un logro desbloqueable en el juego de trivia.
class Achievement {
  /// Identificador único del logro
  final String id;
  
  /// Clave de traducción para el nombre
  final String nameKey;
  
  /// Clave de traducción para la descripción
  final String descriptionKey;
  
  /// Icono del logro (código de IconData)
  final int iconCode;
  
  /// Puntuación requerida para desbloquear
  final int requiredScore;
  
  /// Si el logro está desbloqueado
  final bool isUnlocked;
  
  /// Fecha de desbloqueo (null si no está desbloqueado)
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconCode,
    required this.requiredScore,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      nameKey: nameKey,
      descriptionKey: descriptionKey,
      iconCode: iconCode,
      requiredScore: requiredScore,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameKey': nameKey,
    'descriptionKey': descriptionKey,
    'iconCode': iconCode,
    'requiredScore': requiredScore,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'] as String,
    nameKey: json['nameKey'] as String,
    descriptionKey: json['descriptionKey'] as String,
    iconCode: json['iconCode'] as int,
    requiredScore: json['requiredScore'] as int,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    unlockedAt: json['unlockedAt'] != null 
        ? DateTime.parse(json['unlockedAt'] as String) 
        : null,
  );

  /// Lista de todos los logros disponibles
  static List<Achievement> get allAchievements => [
    const Achievement(
      id: 'first_game',
      nameKey: 'achievementFirstGame',
      descriptionKey: 'achievementFirstGameDesc',
      iconCode: 0xe0b2, // Icons.catching_pokemon
      requiredScore: 0,
    ),
    const Achievement(
      id: 'score_5',
      nameKey: 'achievementScore5',
      descriptionKey: 'achievementScore5Desc',
      iconCode: 0xe838, // Icons.star_border
      requiredScore: 5,
    ),
    const Achievement(
      id: 'score_10',
      nameKey: 'achievementScore10',
      descriptionKey: 'achievementScore10Desc',
      iconCode: 0xe885, // Icons.star_half
      requiredScore: 10,
    ),
    const Achievement(
      id: 'score_25',
      nameKey: 'achievementScore25',
      descriptionKey: 'achievementScore25Desc',
      iconCode: 0xe838, // Icons.star
      requiredScore: 25,
    ),
    const Achievement(
      id: 'score_50',
      nameKey: 'achievementScore50',
      descriptionKey: 'achievementScore50Desc',
      iconCode: 0xf06f, // Icons.military_tech
      requiredScore: 50,
    ),
    const Achievement(
      id: 'score_100',
      nameKey: 'achievementScore100',
      descriptionKey: 'achievementScore100Desc',
      iconCode: 0xe87d, // Icons.emoji_events
      requiredScore: 100,
    ),
  ];
}
