import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../pokedex/data/dto/pokemon_summary_dto.dart';
import '../../../pokedex/domain/entities/pokemon.dart';

class FavoritesLocalDatasource {
  static const String _boxName = 'favorites_box';

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> saveFavorite(Pokemon pokemon) async {
    final box = await _openBox();
    // Convertimos a DTO para facilitar la serialización a JSON map
    // Nota: Necesitarás agregar un método toJson al PokemonSummaryDto o hacerlo manual aquí
    final data = {
      'id': pokemon.id,
      'name': pokemon.name,
      'pokemon_v2_pokemontypes': pokemon.types.map((t) => {
        'pokemon_v2_type': {'name': t.name}
      }).toList(),
    };
    await box.put(pokemon.id, jsonEncode(data));
  }

  Future<void> removeFavorite(int pokemonId) async {
    final box = await _openBox();
    await box.delete(pokemonId);
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
        // Reutilizamos tu DTO existente para convertir de JSON a Entity
        favorites.add(PokemonSummaryDto.fromJson(json).toDomain());
      }
    }
    return favorites;
  }
}