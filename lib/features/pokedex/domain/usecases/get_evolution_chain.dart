import '../entities/pokemon_detail.dart';

/// Caso de uso para procesar datos de cadena evolutiva
class GetEvolutionChain {
  const GetEvolutionChain();

  /// Obtiene la cadena de pre-evoluciones para un Pokémon
  List<EvolutionNode> getPreEvolutions(
    int currentSpeciesId,
    List<EvolutionNode> fullChain,
  ) {
    final speciesMap = {for (final node in fullChain) node.id: node};
    return _buildPreChain(currentSpeciesId, speciesMap);
  }

  /// Obtiene todas las posibles rutas de evolución hacia adelante
  List<List<EvolutionNode>> getForwardEvolutions(
    int currentSpeciesId,
    List<EvolutionNode> fullChain,
  ) {
    final speciesMap = {for (final node in fullChain) node.id: node};
    return _buildForwardChains(currentSpeciesId, speciesMap);
  }

  /// Construye la cadena de pre-evoluciones
  List<EvolutionNode> _buildPreChain(
    int currentId,
    Map<int, EvolutionNode> speciesMap,
  ) {
    final chain = <EvolutionNode>[];
    int? cursor = currentId;

    while (cursor != null) {
      final node = speciesMap[cursor];
      if (node == null) break;
      chain.insert(0, node);
      cursor = node.evolvesFromId;
    }

    return chain;
  }

  /// Construye todas las cadenas de evolución hacia adelante
  List<List<EvolutionNode>> _buildForwardChains(
    int currentId,
    Map<int, EvolutionNode> speciesMap,
  ) {
    List<EvolutionNode> getChildren(int parentId) {
      return speciesMap.values
          .where((node) => node.evolvesFromId == parentId)
          .toList();
    }

    final result = <List<EvolutionNode>>[];
    final firstLevel = getChildren(currentId);

    for (final child in firstLevel) {
      final chain = <EvolutionNode>[child];
      var cursor = child;

      while (true) {
        final children = getChildren(cursor.id);
        if (children.length == 1) {
          cursor = children.first;
          chain.add(cursor);
        } else {
          break;
        }
      }

      result.add(chain);
    }

    return result;
  }
}

