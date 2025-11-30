import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/graphql/graphql_client_provider.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/services/location_service.dart';
import '../../domain/entities/location.dart';

/// Provider para el servicio de ubicaciones
final locationServiceProvider = Provider<LocationService>((ref) {
  final clientNotifier = ref.watch(graphqlClientProvider);
  return LocationService(clientNotifier.value);
});

/// Provider para el repositorio de ubicaciones
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final service = ref.watch(locationServiceProvider);
  return LocationRepository(service);
});

/// Provider family para cargar una ubicación por nombre
/// 
/// Uso:
/// ```dart
/// final locationAsync = ref.watch(locationByNameProvider('pallet-town'));
/// ```
final locationByNameProvider =
    FutureProvider.family<LocationDetail?, String>((ref, locationName) async {
  final repository = ref.watch(locationRepositoryProvider);
  return await repository.getLocationByName(locationName);
});

/// Provider family para cargar una ubicación por ID
/// 
/// Uso:
/// ```dart
/// final locationAsync = ref.watch(locationByIdProvider(1));
/// ```
final locationByIdProvider =
    FutureProvider.family<LocationDetail?, int>((ref, locationId) async {
  final repository = ref.watch(locationRepositoryProvider);
  return await repository.getLocationById(locationId);
});
