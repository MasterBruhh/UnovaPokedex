import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pokedex/domain/entities/pokemon.dart';
import '../../data/datasources/favorites_local_datasource.dart';

// Provider para el Datasource
final favoritesDatasourceProvider = Provider((ref) => FavoritesLocalDatasource());

// Provider para el estado de la lista de favoritos
final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Pokemon>>(FavoritesNotifier.new);

class FavoritesNotifier extends Notifier<List<Pokemon>> {
  late final FavoritesLocalDatasource _datasource;

  @override
  List<Pokemon> build() {
    _datasource = ref.read(favoritesDatasourceProvider);
    _loadFavorites();
    return [];
  }

  Future<void> _loadFavorites() async {
    final list = await _datasource.getFavorites();
    // Ordenamos por ID para mantener consistencia
    list.sort((a, b) => a.id.compareTo(b.id));
    state = list;
  }

  Future<void> toggleFavorite(Pokemon pokemon) async {
    final isFav = state.any((p) => p.id == pokemon.id);

    if (isFav) {
      await _datasource.removeFavorite(pokemon.id);
      state = state.where((p) => p.id != pokemon.id).toList();
    } else {
      await _datasource.saveFavorite(pokemon);
      final newList = [...state, pokemon];
      newList.sort((a, b) => a.id.compareTo(b.id));
      state = newList;
    }
  }

  bool isFavorite(int id) {
    return state.any((p) => p.id == id);
  }
}