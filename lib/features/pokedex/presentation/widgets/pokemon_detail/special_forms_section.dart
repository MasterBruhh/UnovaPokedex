import 'package:flutter/material.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../domain/entities/pokemon_form.dart';

/// Widget que muestra las formas especiales de un Pokémon
/// Muestra cada forma como una cadena: Base → Catalizador → Forma Especial
class SpecialFormsSection extends StatelessWidget {
  const SpecialFormsSection({
    super.key,
    required this.forms,
    required this.baseName,
    required this.baseId,
    this.megaStones = const [],
    this.onTapForm,
  });

  final List<PokemonForm> forms;
  final String baseName;
  final int baseId;
  final List<Map<String, dynamic>> megaStones;
  final void Function(PokemonForm form)? onTapForm;

  @override
  Widget build(BuildContext context) {
    if (forms.isEmpty) {
      return const Text(
        'Este Pokémon no tiene formas especiales.',
        style: TextStyle(color: Colors.white70),
      );
    }

    // Agrupar por tipo de forma
    final megaForms = forms.where((f) => f.formType == SpecialFormType.mega).toList();
    final gmaxForms = forms.where((f) => f.formType == SpecialFormType.gmax).toList();
    final regionalForms = forms.where((f) => f.formType == SpecialFormType.regional).toList();
    final alternateForms = forms.where((f) => f.formType == SpecialFormType.alternate).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mega Evoluciones
        if (megaForms.isNotEmpty) ...[
          _buildCategoryHeader('Mega Evoluciones', Icons.flash_on, Colors.purple.shade200),
          const SizedBox(height: 12),
          _buildFormChainList(megaForms, _getMegaCatalyst),
          const SizedBox(height: 16),
        ],

        // Formas Gigantamax
        if (gmaxForms.isNotEmpty) ...[
          _buildCategoryHeader('Formas Gigantamax', Icons.cloud, Colors.redAccent),
          const SizedBox(height: 12),
          _buildFormChainList(gmaxForms, _getGmaxCatalyst),
          const SizedBox(height: 16),
        ],

        // Formas Regionales
        if (regionalForms.isNotEmpty) ...[
          _buildCategoryHeader('Formas Regionales', Icons.public, Colors.teal),
          const SizedBox(height: 12),
          _buildFormChainList(regionalForms, _getRegionalCatalyst),
          const SizedBox(height: 16),
        ],

        // Otras Formas
        if (alternateForms.isNotEmpty) ...[
          _buildCategoryHeader('Otras Variantes', Icons.auto_awesome, Colors.amber),
          const SizedBox(height: 12),
          _buildFormChainList(alternateForms, _getAlternateCatalyst),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFormChainList(
    List<PokemonForm> categoryForms,
    Map<String, dynamic> Function(PokemonForm) getCatalyst,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < categoryForms.length; i++) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildFormChainRow(categoryForms[i], getCatalyst),
          ),
          if (i < categoryForms.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// Construye una fila: Base → Catalizador → Forma Especial
  Widget _buildFormChainRow(
    PokemonForm form,
    Map<String, dynamic> Function(PokemonForm) getCatalyst,
  ) {
    final catalyst = getCatalyst(form);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pokémon base
        _buildPokemonNode(
          id: baseId,
          name: _capitalizeFirst(baseName),
          isBase: true,
        ),

        // Flecha con catalizador
        _buildCatalystArrow(catalyst),

        // Forma especial (clicable)
        _buildPokemonNode(
          id: form.id,
          name: _getFormDisplayName(form),
          isBase: false,
          types: form.types.map((t) => t.name).toList(),
          onTap: onTapForm != null ? () => onTapForm!(form) : null,
        ),
      ],
    );
  }

  Widget _buildPokemonNode({
    required int id,
    required String name,
    required bool isBase,
    List<String>? types,
    VoidCallback? onTap,
  }) {
    final spriteUrl = PokemonSpriteUtils.getArtworkUrl(id);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: isBase ? Colors.white24 : Colors.white.withOpacity(0.15),
          radius: 36,
          child: Image.network(
            spriteUrl,
            height: 52,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.network(
              PokemonSpriteUtils.getSpriteUrl(id),
              height: 52,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                color: Colors.white54,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            color: isBase ? Colors.white : Colors.white70,
            fontWeight: isBase ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        // Mostrar tipos para la forma especial
        if (types != null && types.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: types
                .map((type) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
        // Indicador de que es clicable
        if (onTap != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Ver detalles',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildCatalystArrow(Map<String, dynamic> catalyst) {
    final catalystName = catalyst['name'] as String;
    final catalystIcon = catalyst['icon'] as IconData;
    final catalystColor = catalyst['color'] as Color;
    final itemSprite = catalyst['itemSprite'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contenedor del catalizador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: catalystColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: catalystColor.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sprite del item si existe
                if (itemSprite != null)
                  Image.network(
                    itemSprite,
                    height: 24,
                    width: 24,
                    errorBuilder: (_, __, ___) => Icon(
                      catalystIcon,
                      color: catalystColor,
                      size: 18,
                    ),
                  )
                else
                  Icon(catalystIcon, color: catalystColor, size: 18),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 80),
                  child: Text(
                    catalystName,
                    style: TextStyle(
                      color: catalystColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        ],
      ),
    );
  }

  /// Obtiene el catalizador para una mega evolución
  Map<String, dynamic> _getMegaCatalyst(PokemonForm form) {
    String stoneName = 'Mega Piedra';
    String? itemSprite;

    // Intentar encontrar la mega stone correspondiente
    for (final stone in megaStones) {
      final stoneNameStr = stone['name'] as String;
      final stoneNameLower = stoneNameStr.toLowerCase();
      final formNameLower = form.formName.toLowerCase();

      // Verificar si es la piedra correcta (ej: charizardite-x para mega-x)
      if (formNameLower.contains('x') && stoneNameLower.contains('x')) {
        stoneName = stoneNameStr;
        itemSprite = _getMegaStoneSprite(stoneNameStr);
        break;
      } else if (formNameLower.contains('y') && stoneNameLower.contains('y')) {
        stoneName = stoneNameStr;
        itemSprite = _getMegaStoneSprite(stoneNameStr);
        break;
      } else if (!formNameLower.contains('x') && !formNameLower.contains('y') &&
          !stoneNameLower.contains('x') && !stoneNameLower.contains('y')) {
        stoneName = stoneNameStr;
        itemSprite = _getMegaStoneSprite(stoneNameStr);
        break;
      }
    }

    // Si no se encontró mega stone, generar nombre genérico
    if (megaStones.isEmpty) {
      final pokemonBase = baseName.toLowerCase();
      if (form.formName.contains('x')) {
        stoneName = '${_capitalizeFirst(pokemonBase)}ita X';
      } else if (form.formName.contains('y')) {
        stoneName = '${_capitalizeFirst(pokemonBase)}ita Y';
      } else {
        stoneName = '${_capitalizeFirst(pokemonBase)}ita';
      }
    }

    return {
      'name': stoneName,
      'icon': Icons.diamond,
      'color': Colors.purple.shade200,
      'itemSprite': itemSprite,
    };
  }

  String? _getMegaStoneSprite(String stoneName) {
    // Convertir nombre a sprite name
    final spriteName = stoneName
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/$spriteName.png';
  }

  /// Obtiene el catalizador para una forma Gigantamax
  Map<String, dynamic> _getGmaxCatalyst(PokemonForm form) {
    return {
      'name': 'Factor\nGigantamax',
      'icon': Icons.cloud,
      'color': Colors.redAccent,
      'itemSprite': null,
    };
  }

  /// Obtiene el catalizador para una forma regional
  Map<String, dynamic> _getRegionalCatalyst(PokemonForm form) {
    final region = form.regionName ?? 'Región';
    return {
      'name': 'Variante\n$region',
      'icon': Icons.public,
      'color': Colors.teal,
      'itemSprite': null,
    };
  }

  /// Obtiene el catalizador para otras formas
  Map<String, dynamic> _getAlternateCatalyst(PokemonForm form) {
    return {
      'name': 'Cambio\nde forma',
      'icon': Icons.auto_awesome,
      'color': Colors.amber,
      'itemSprite': null,
    };
  }

  String _getFormDisplayName(PokemonForm form) {
    if (form.displayName.isNotEmpty && form.displayName != form.name) {
      return form.displayName;
    }

    final formName = form.formName;
    if (formName.isEmpty) {
      return _capitalizeFirst(baseName);
    }

    // Limpiar y formatear
    String cleaned = formName
        .replaceAll('-', ' ')
        .replaceAll('mega ', 'Mega ')
        .replaceAll('gmax', 'Gigantamax');

    // Capitalizar
    return cleaned.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getTypeColor(String type) {
    final typeColors = {
      'normal': const Color(0xFFA8A878),
      'fire': const Color(0xFFF08030),
      'water': const Color(0xFF6890F0),
      'electric': const Color(0xFFF8D030),
      'grass': const Color(0xFF78C850),
      'ice': const Color(0xFF98D8D8),
      'fighting': const Color(0xFFC03028),
      'poison': const Color(0xFFA040A0),
      'ground': const Color(0xFFE0C068),
      'flying': const Color(0xFFA890F0),
      'psychic': const Color(0xFFF85888),
      'bug': const Color(0xFFA8B820),
      'rock': const Color(0xFFB8A038),
      'ghost': const Color(0xFF705898),
      'dragon': const Color(0xFF7038F8),
      'dark': const Color(0xFF705848),
      'steel': const Color(0xFFB8B8D0),
      'fairy': const Color(0xFFEE99AC),
    };
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }
}
