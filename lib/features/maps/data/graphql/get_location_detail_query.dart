/// Query GraphQL para obtener detalles de una ubicación
/// 
/// Retorna información completa de una ubicación incluyendo:
/// - Datos básicos de la ubicación
/// - Región a la que pertenece
/// - Áreas dentro de la ubicación
/// - Pokémon disponibles en cada área con niveles y rareza
/// - Métodos de encuentro
/// - Versiones del juego
const String getLocationDetailQuery = r'''
  query LocationDetails($where: pokemon_v2_location_bool_exp!) {
    pokemon_v2_location(where: $where, limit: 1) {
      id
      name
      pokemon_v2_region {
        id
        name
      }
      pokemon_v2_locationareas {
        id
        name
        pokemon_v2_encounters {
          min_level
          max_level
          pokemon_v2_pokemon {
            id
            name
          }
          pokemon_v2_version {
            id
            name
          }
          pokemon_v2_encounterslot {
            id
            rarity
            pokemon_v2_encountermethod {
              name
            }
          }
        }
      }
    }
  }
''';

/// Variables para buscar ubicación por nombre
/// 
/// Uso:
/// ```dart
/// final variables = getLocationVariablesByName('pallet-town');
/// ```
Map<String, dynamic> getLocationVariablesByName(String locationName) {
  return {
    'where': {
      'name': {
        '_eq': locationName,
      }
    }
  };
}

/// Variables para buscar ubicación por ID
/// 
/// Uso:
/// ```dart
/// final variables = getLocationVariablesById(1);
/// ```
Map<String, dynamic> getLocationVariablesById(int locationId) {
  return {
    'where': {
      'id': {
        '_eq': locationId,
      }
    }
  };
}
