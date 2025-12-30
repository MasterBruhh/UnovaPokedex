import 'package:flutter/material.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_region.dart';
import '../../../domain/entities/pokemon_type.dart';
import '../../providers/pokemon_list_provider.dart';
import '../../utils/pokemon_region_colors.dart';
import '../../utils/pokemon_type_colors.dart';

/// Widget de hoja inferior para filtrar Pokémon
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.searchText,
    required this.selectedTypes,
    required this.selectedRegions,
    required this.sortOption,
    required this.isLoadingAll,
    required this.onSearchChanged,
    required this.onTypeToggled,
    required this.onRegionToggled,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  final String searchText;
  final Set<PokemonType> selectedTypes;
  final Set<PokemonRegion> selectedRegions;
  final SortOption sortOption;
  final bool isLoadingAll;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PokemonType> onTypeToggled;
  final ValueChanged<PokemonRegion> onRegionToggled;
  final ValueChanged<SortOption> onSortChanged;
  final VoidCallback onClearFilters;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchText);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.numberAsc:
        return 'Número ↑';
      case SortOption.numberDesc:
        return 'Número ↓';
      case SortOption.nameAsc:
        return 'Nombre A-Z';
      case SortOption.nameDesc:
        return 'Nombre Z-A';
    }
  }

  bool get _hasActiveFilters =>
      widget.searchText.isNotEmpty ||
      widget.selectedTypes.isNotEmpty ||
      widget.selectedRegions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y botón de limpiar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros y Ordenación',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    widget.onClearFilters();
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Limpiar'),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Indicador de carga
          if (widget.isLoadingAll)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cargando todos los Pokémon para filtrar...',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          
          // Búsqueda
          TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              labelText: 'Buscar por nombre o número...',
              hintText: 'Ej: pikachu, 25, #025',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Ordenación
          const Text(
            'Ordenar por',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: SortOption.values.map((option) {
              final isSelected = widget.sortOption == option;
              return ChoiceChip(
                label: Text(_getSortLabel(option)),
                selected: isSelected,
                onSelected: (_) => widget.onSortChanged(option),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Tipos
          const Text(
            'Tipos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: PokemonType.values.map((type) {
              final isSelected = widget.selectedTypes.contains(type);
              return FilterChip(
                label: Text(type.name.toTitleCase()),
                selected: isSelected,
                onSelected: (_) => widget.onTypeToggled(type),
                selectedColor: PokemonTypeColors.getColor(type).withOpacity(0.8),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Regiones
          const Text(
            'Regiones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: PokemonRegion.values.map((region) {
              final isSelected = widget.selectedRegions.contains(region);
              return FilterChip(
                label: Text(region.name.toTitleCase()),
                selected: isSelected,
                onSelected: (_) => widget.onRegionToggled(region),
                selectedColor: PokemonRegionColors.getColor(region).withOpacity(0.85),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

