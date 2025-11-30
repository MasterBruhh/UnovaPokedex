import '../../domain/entities/location.dart';
import '../services/location_service.dart';

/// Repositorio para gestionar ubicaciones con caché en memoria
/// 
/// Implementa una capa de caché simple para reducir llamadas a la API.
/// El caché se mantiene durante la vida de la aplicación.
class LocationRepository {
  final LocationService _service;
  
  /// Caché de ubicaciones por nombre
  final Map<String, LocationDetail> _cacheByName = {};
  
  /// Caché de ubicaciones por ID
  final Map<int, LocationDetail> _cacheById = {};

  LocationRepository(this._service);

  /// Obtiene una ubicación por nombre, usando caché si está disponible
  /// 
  /// [locationName] debe ser el nombre en formato kebab-case
  /// [forceRefresh] fuerza una nueva petición ignorando el caché
  Future<LocationDetail?> getLocationByName(
    String locationName, {
    bool forceRefresh = false,
  }) async {
    // Si no forzamos refresh y tenemos el dato en caché, lo retornamos
    if (!forceRefresh && _cacheByName.containsKey(locationName)) {
      return _cacheByName[locationName];
    }
    final location = await _service.fetchLocationByName(locationName);
    
    if (location != null) {
      // Guardamos en ambos cachés
      _cacheByName[locationName] = location;
      _cacheById[location.id] = location;
    }
    
    return location;
  }

  /// Obtiene una ubicación por ID, usando caché si está disponible
  /// 
  /// [forceRefresh] fuerza una nueva petición ignorando el caché
  Future<LocationDetail?> getLocationById(
    int locationId, {
    bool forceRefresh = false,
  }) async {
    // Si no forzamos refresh y tenemos el dato en caché, lo retornamos
    if (!forceRefresh && _cacheById.containsKey(locationId)) {
      return _cacheById[locationId];
    }
    final location = await _service.fetchLocationById(locationId);
    
    if (location != null) {
      // Guardamos en ambos cachés
      _cacheById[locationId] = location;
      _cacheByName[location.name] = location;
    }
    
    return location;
  }

  /// Limpia el caché completamente
  void clearCache() {
    _cacheByName.clear();
    _cacheById.clear();
  }

  /// Elimina una ubicación específica del caché
  void invalidateLocation(String locationName) {
    final location = _cacheByName[locationName];
    _cacheByName.remove(locationName);
    if (location != null) {
      _cacheById.remove(location.id);
    }
  }

  /// Retorna el número de elementos en caché
  int get cacheSize => _cacheByName.length;
}
