import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/pokemon_sprite_utils.dart';
import '../../../../../core/utils/string_extensions.dart';
import '../../../domain/entities/pokemon_detail.dart';
import '../pokemon_list/type_color_bar.dart';

/// Widget que representa la tarjeta diseñada específicamente para ser compartida como imagen.
/// Imita el diseño de la referencia proporcionada.
class PokemonShareCard extends StatelessWidget {
  const PokemonShareCard({super.key, required this.pokemon});

  final PokemonDetail pokemon;

  // Función auxiliar para obtener el valor de una estadística desde la lista de forma segura
  int _getStat(String statName) {
    // Buscamos en la lista stats donde el nombre coincida (ej: 'hp', 'attack')
    // Si no se encuentra, devolvemos 0 para evitar errores
    final stat = pokemon.stats.firstWhere(
          (s) => s.name == statName,
      orElse: () => const PokemonStat(name: '', baseStat: 0),
    );
    return stat.baseStat;
  }

  @override
  Widget build(BuildContext context) {
    // Colores específicos basados en la imagen de referencia
    const cardBackgroundColor = Color(0xFF2C2C2C);
    const statsBlockColor = Color(0xFF1A1A1A);
    const textColor = Colors.white;

    return Container(
      width: 300, // Ancho fijo para asegurar consistencia al compartir
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mediumBrown, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header: Nombre y ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pokemon.name.toTitleCase(),
                style: const TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '#${pokemon.id}',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Imagen Principal (Artwork oficial)
          Hero(
            tag: 'share-card-${pokemon.id}', // Tag único para evitar conflictos
            child: Image.network(
              PokemonSpriteUtils.getArtworkUrl(pokemon.id),
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 50, color: Colors.white54);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Tipos
          TypeColorBar(types: pokemon.types),
          const SizedBox(height: 16),

          // --- DESCRIPCIÓN (NUEVO LUGAR) ---
          if (pokemon.description.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pokemon.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 13,
                  fontStyle: FontStyle.normal,
                  height: 1.4,
                ),
                maxLines: 4, // Limitar líneas para que no rompa el diseño
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // ---------------------------------

          // Bloque de Estadísticas (Diseño compacto de referencia)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: statsBlockColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildCompactStatRow('HP', _getStat('hp'), 'ATK', _getStat('attack'), textColor),
                const SizedBox(height: 8),
                _buildCompactStatRow('DEF', _getStat('defense'), 'SATK', _getStat('special-attack'), textColor),
                const SizedBox(height: 8),
                _buildCompactStatRow('SDEF', _getStat('special-defense'), 'SPD', _getStat('speed'), textColor),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Footer: Branding
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.catching_pokemon, color: AppColors.beige, size: 20),
              SizedBox(width: 8),
              Text(
                'Unova Pokedex',
                style: TextStyle(
                  color: AppColors.beige,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatRow(
      String label1, int value1, String label2, int value2, Color textColor) {
    return Row(
      children: [
        Expanded(child: _buildSingleStat(label1, value1, textColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStat(label2, value2, textColor)),
      ],
    );
  }

  Widget _buildSingleStat(String label, int value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold)),
        Text(value.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}