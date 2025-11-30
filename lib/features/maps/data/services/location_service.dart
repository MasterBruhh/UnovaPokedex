import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/entities/location.dart';
import '../graphql/get_location_detail_query.dart';

/// Servicio para interactuar con la API GraphQL de ubicaciones
/// 
/// Responsable de ejecutar queries GraphQL y transformar las respuestas
/// en objetos de dominio.
class LocationService {
  /// Cliente GraphQL para realizar las peticiones
  final GraphQLClient _client;

  LocationService(this._client);

  /// Obtiene los detalles de una ubicación por su nombre
  /// 
  /// [locationName] debe ser el nombre en formato kebab-case (ej: 'pallet-town')
  /// 
  /// Retorna `null` si no se encuentra la ubicación o hay un error.
  /// 
  /// Ejemplo:
  /// ```dart
  /// final location = await service.fetchLocationByName('pallet-town');
  /// ```
  Future<LocationDetail?> fetchLocationByName(String locationName) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(getLocationDetailQuery),
        variables: getLocationVariablesByName(locationName),
        fetchPolicy: FetchPolicy.cacheFirst,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        return null;
      }

      final data = result.data;
      if (data == null) {
        return null;
      }

      final locations = data['pokemon_v2_location'] as List<dynamic>?;
      if (locations == null || locations.isEmpty) {
        return null;
      }

      final locationData = locations.first as Map<String, dynamic>;
      final location = LocationDetail.fromJson(locationData);
      
      return location;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene los detalles de una ubicación por su ID
  /// 
  /// Retorna `null` si no se encuentra la ubicación o hay un error.
  Future<LocationDetail?> fetchLocationById(int locationId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(getLocationDetailQuery),
        variables: getLocationVariablesById(locationId),
        fetchPolicy: FetchPolicy.cacheFirst,
      );

      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        return null;
      }

      final data = result.data;
      if (data == null) {
        return null;
      }

      final locations = data['pokemon_v2_location'] as List<dynamic>?;
      if (locations == null || locations.isEmpty) {
        return null;
      }

      final locationData = locations.first as Map<String, dynamic>;
      final location = LocationDetail.fromJson(locationData);
      
      return location;
    } catch (e) {
      return null;
    }
  }
}
