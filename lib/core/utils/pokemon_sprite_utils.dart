import '../config/app_constants.dart';

/// Funciones de utilidad para URLs de sprites de Pokémon
class PokemonSpriteUtils {
  // Constructor privado para prevenir instanciación
  PokemonSpriteUtils._();

  /// Devuelve la URL del sprite estándar para un Pokémon por ID
  static String getSpriteUrl(int pokemonId) {
    return '${AppConstants.pokemonSpriteBaseUrl}/$pokemonId.png';
  }

  /// Devuelve la URL del artwork oficial para un Pokémon por ID
  static String getArtworkUrl(int pokemonId) {
    return '${AppConstants.pokemonArtworkBaseUrl}/$pokemonId.png';
  }

  /// Devuelve la URL del artwork oficial shiny para un Pokémon por ID
  static String getShinyArtworkUrl(int pokemonId) {
    return '${AppConstants.pokemonShinyArtworkBaseUrl}/$pokemonId.png';
  }

  /// Devuelve la URL del sprite shiny para un Pokémon por ID
  static String getShinySpriteUrl(int pokemonId) {
    return '${AppConstants.pokemonSpriteBaseUrl}/shiny/$pokemonId.png';
  }
}

