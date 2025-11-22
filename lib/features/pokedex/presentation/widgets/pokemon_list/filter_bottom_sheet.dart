import 'package:flutter/material.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_region.dart';
import '../../../domain/entities/pokemon_type.dart';
import '../../utils/pokemon_region_colors.dart';
import '../../utils/pokemon_type_colors.dart';

/// Widget de hoja inferior para filtrar Pokémon
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
    required this.searchText,
    required this.selectedTypes,
    required this.selectedRegions,
    required this.onSearchChanged,
    required this.onTypeToggled,
    required this.onRegionToggled,
  });

  final String searchText;
  final Set<PokemonType> selectedTypes;
  final Set<PokemonRegion> selectedRegions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PokemonType> onTypeToggled;
  final ValueChanged<PokemonRegion> onRegionToggled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        runSpacing: 16,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              labelText: 'Buscar por nombre...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: PokemonType.values.map((type) {
              final isSelected = selectedTypes.contains(type);
              return FilterChip(
                label: Text(type.name.toTitleCase()),
                selected: isSelected,
                onSelected: (_) => onTypeToggled(type),
                selectedColor: PokemonTypeColors.getColor(type).withOpacity(0.8),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Regiones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: PokemonRegion.values.map((region) {
              final isSelected = selectedRegions.contains(region);
              return FilterChip(
                label: Text(region.name.toTitleCase()),
                selected: isSelected,
                onSelected: (_) => onRegionToggled(region),
                selectedColor: PokemonRegionColors.getColor(region).withOpacity(0.85),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

