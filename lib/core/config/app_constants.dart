/// Constantes de toda la aplicación
class AppConstants {
  // Constructor privado para prevenir instanciación
  AppConstants._();

  // Configuración de API
  static const String defaultGraphqlEndpoint =
      'https://beta.pokeapi.co/graphql/v1beta2';

  // URLs de sprites de Pokémon
  static const String pokemonSpriteBaseUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';
  static const String pokemonArtworkBaseUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';
  static const String pokemonShinyArtworkBaseUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny';

  // Límites de datos de Pokémon
  static const int maxPokemonId = 1025;
  static const int englishLanguageId = 9;
  static const int spanishLanguageId = 7;

  // Rangos de ID de Pokédex regionales
  static const int kantoMax = 151;
  static const int johtoMax = 251;
  static const int hoennMax = 386;
  static const int sinnohMax = 493;
  static const int unovaMax = 649;
  static const int kalosMax = 721;
  static const int alolaMax = 809;
  static const int galarMax = 898;
  static const int hisuiMax = 905;

  // Mapeo de nombres de estadísticas (API a español)
  static const Map<String, String> statNamesSpanish = {
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'At. Esp.',
    'special-defense': 'Def. Esp.',
    'speed': 'Velocidad',
  };

  // Assets de audio
  static const String pokeballSfxPath = 'audio/pokeball_sound.mp3';
  static const String pokemonCenterBgmPath = 'audio/pokemon_center.mp3';

  // Constantes de UI
  static const double defaultCardElevation = 4.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
}

