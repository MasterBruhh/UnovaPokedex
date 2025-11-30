import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/map_area.dart';
import '../../domain/entities/location.dart';
import '../providers/location_provider.dart';

/// Diálogo modal que muestra información de una ubicación del mapa
/// 
/// Carga dinámicamente los datos de la ubicación desde PokeAPI GraphQL
/// y muestra la lista de Pokémon disponibles en esa área.
class LocationInfoDialog extends ConsumerWidget {
  /// Área del mapa a mostrar
  final MapArea area;
  
  /// Nombre de la región (para contexto adicional)
  final String regionName;

  const LocationInfoDialog({
    super.key,
    required this.area,
    required this.regionName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si no hay locationId, mostramos info básica
    final hasLocationId = area.locationId != null && area.locationId!.isNotEmpty;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.place, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              area.title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: hasLocationId
            ? _buildAsyncContent(context, ref)
            : _buildBasicInfo(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildAsyncContent(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationByNameProvider(area.locationId!));
    
    return locationAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (location) {
        if (location == null) {
          return _buildBasicInfo();
        }
        return _buildLocationWithPokemon(location);
      },
    );
  }

  /// Construye la vista básica sin datos de Pokémon
  Widget _buildBasicInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Icons.location_on,
          label: 'Location',
          value: area.title,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.map,
          label: 'Region',
          value: regionName,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.category,
          label: 'Type',
          value: area.shape,
          valueColor: Colors.grey,
        ),
      ],
    );
  }

  /// Construye la vista con información de Pokémon
  Widget _buildLocationWithPokemon(LocationDetail location) {
    final pokemonList = location.allUniquePokemon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info básica
        _buildInfoRow(
          icon: Icons.location_on,
          label: 'Location',
          value: location.displayName,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.map,
          label: 'Region',
          value: location.region.displayName,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.catching_pokemon,
          label: 'Pokémon Available',
          value: '${pokemonList.length} species',
          valueColor: Colors.green.shade700,
        ),
        
        // Lista de Pokémon
        if (pokemonList.isNotEmpty) ...[
          const Divider(height: 24),
          const Text(
            'Available Pokémon:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                return _buildPokemonCard(pokemon);
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Construye una tarjeta para mostrar un Pokémon
  Widget _buildPokemonCard(PokemonEncounter pokemon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del Pokémon (lado izquierdo)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del Pokémon
                  Row(
                    children: [
                      const Icon(Icons.catching_pokemon, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pokemon.displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Niveles
                  _buildPokemonDetail(
                    icon: Icons.star,
                    label: 'Level',
                    value: pokemon.levelRange,
                    color: Colors.amber.shade700,
                  ),
                  
                  // Rareza
                  _buildPokemonDetail(
                    icon: Icons.percent,
                    label: 'Rarity',
                    value: pokemon.rarityPercentage,
                    color: Colors.purple.shade600,
                  ),
                  
                  // Método de encuentro
                  _buildPokemonDetail(
                    icon: Icons.route,
                    label: 'Method',
                    value: pokemon.encounterMethod,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
            
            // Sprite del Pokémon (lado derecho)
            const SizedBox(width: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  pokemon.spriteUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.catching_pokemon,
                      color: Colors.grey.shade400,
                      size: 32,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un detalle del Pokémon
  Widget _buildPokemonDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado de error
  Widget _buildErrorState(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
        const SizedBox(height: 16),
        Text(
          'Error loading location data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildBasicInfo(),
      ],
    );
  }

  /// Construye una fila de información con ícono y texto
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
