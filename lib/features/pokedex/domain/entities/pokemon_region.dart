import '../../../../core/config/app_constants.dart';

/// Enumeración de regiones de Pokémon
enum PokemonRegion {
  kanto,
  johto,
  hoenn,
  sinnoh,
  unova,
  kalos,
  alola,
  galar,
  paldea,
  hisui;

  /// Determina la región basada en el ID del Pokémon
  static PokemonRegion fromPokemonId(int id) {
    if (id <= AppConstants.kantoMax) return PokemonRegion.kanto;
    if (id <= AppConstants.johtoMax) return PokemonRegion.johto;
    if (id <= AppConstants.hoennMax) return PokemonRegion.hoenn;
    if (id <= AppConstants.sinnohMax) return PokemonRegion.sinnoh;
    if (id <= AppConstants.unovaMax) return PokemonRegion.unova;
    if (id <= AppConstants.kalosMax) return PokemonRegion.kalos;
    if (id <= AppConstants.alolaMax) return PokemonRegion.alola;
    if (id <= AppConstants.galarMax) return PokemonRegion.galar;
    if (id <= AppConstants.hisuiMax) return PokemonRegion.hisui;
    return PokemonRegion.paldea;
  }
}

