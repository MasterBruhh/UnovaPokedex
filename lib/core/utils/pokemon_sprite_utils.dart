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
}

