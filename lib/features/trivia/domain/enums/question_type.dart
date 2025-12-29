/// Tipos de preguntas disponibles en el juego de trivia.
/// 
/// El juego tiene dos tipos de preguntas:
/// - [silhouette]: "¿Quién es ese Pokémon?" con una silueta negra
/// - [description]: "¿Qué Pokémon coincide con esta descripción?" con texto
enum QuestionType {
  /// Pregunta mostrando una silueta de Pokémon (sombra negra)
  silhouette,
  
  /// Pregunta mostrando una descripción de Pokémon (flavor text)
  description,
}
