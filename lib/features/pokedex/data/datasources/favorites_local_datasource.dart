import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/utils/sprite_cache_service.dart';
import '../../../pokedex/data/dto/pokemon_summary_dto.dart';
import '../../../pokedex/domain/entities/pokemon.dart';

class FavoritesLocalDatasource {
  static const String _boxName = 'favorites_box';
  final SpriteCacheService _spriteCache = SpriteCacheService.instance;

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  /// Guarda un Pokémon en favoritos con toda su información esencial:
  /// - ID
  /// - Nombre
  /// - Tipos
  /// - Sprite normal (descargado y guardado localmente)
  /// - Sprite shiny (descargado y guardado localmente)
  /// 
  /// NO guarda: evoluciones, formas especiales, stats, movimientos, etc.
  Future<void> saveFavorite(Pokemon pokemon) async {
    final box = await _openBox();
    
    // Descargar y cachear los sprites localmente
    final sprites = await _spriteCache.cacheAllSprites(pokemon.id);
    
    // Guardamos la información esencial del Pokémon favorito
    // con las rutas locales de los sprites
    final data = {
      'id': pokemon.id,
      'name': pokemon.name,
      'pokemon_v2_pokemontypes': pokemon.types.map((t) => {
        'pokemon_v2_type': {'name': t.name}
      }).toList(),
      // Rutas locales de los sprites cacheados
      'spriteUrl': sprites['sprite'],
      'shinySpriteUrl': sprites['shiny'],
    };
    
    await box.put(pokemon.id, jsonEncode(data));
  }

  Future<void> removeFavorite(int pokemonId) async {
    final box = await _openBox();
    await box.delete(pokemonId);
    
    // También eliminamos los sprites cacheados
    await _spriteCache.deleteSprites(pokemonId);
  }

  Future<bool> isFavorite(int pokemonId) async {
    final box = await _openBox();
    return box.containsKey(pokemonId);
  }

  Future<List<Pokemon>> getFavorites() async {
    final box = await _openBox();
    final List<Pokemon> favorites = [];

    for (var key in box.keys) {
      final jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        // Convertimos el JSON guardado a entidad Pokemon con rutas locales de sprites
        favorites.add(PokemonSummaryDto.fromJson(json).toDomain());
      }
    }
    return favorites;
  }
}