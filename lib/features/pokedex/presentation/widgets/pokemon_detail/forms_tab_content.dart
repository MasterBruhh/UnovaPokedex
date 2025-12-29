import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/pokemon_detail.dart';
import '../../../domain/entities/pokemon_form.dart';
import '../../../domain/usecases/get_evolution_chain.dart';
import '../../providers/evolution_forms_providers.dart';
import 'evolution_section.dart';
import 'pokemon_info_card.dart';
import 'special_forms_section.dart';

/// Contenido de la pestaña "Formas"
/// Muestra las evoluciones y formas especiales del Pokémon
class FormsTabContent extends ConsumerWidget {
  const FormsTabContent({
    super.key,
    required this.pokemon,
    required this.evolutionUseCase,
    required this.onTapSpecies,
    this.onTapForm,
  });

  final PokemonDetail pokemon;
  final GetEvolutionChain evolutionUseCase;
  final ValueChanged<String> onTapSpecies;
  final void Function(PokemonForm form)? onTapForm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener detalles de evolución
    final evolutionDetailsAsync = ref.watch(evolutionDetailsProvider(pokemon.evolutionChainId));

    // Obtener formas alternativas
    final formsAsync = ref.watch(pokemonFormsProvider(pokemon.speciesId));

    // Obtener mega stones
    final megaStonesAsync = ref.watch(megaStonesProvider(pokemon.name.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sección de evoluciones
        if (pokemon.evolutionChain.isNotEmpty)
          PokemonInfoCard(
            title: 'Evoluciones',
            child: evolutionDetailsAsync.when(
              data: (evolutionDetails) => EvolutionSection(
                pokemon: pokemon,
                evolutionUseCase: evolutionUseCase,
                onTapSpecies: onTapSpecies,
                evolutionDetails: evolutionDetails.cast(),
              ),
              loading: () => Column(
                children: [
                  EvolutionSection(
                    pokemon: pokemon,
                    evolutionUseCase: evolutionUseCase,
                    onTapSpecies: onTapSpecies,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Cargando condiciones...',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              error: (_, __) => EvolutionSection(
                pokemon: pokemon,
                evolutionUseCase: evolutionUseCase,
                onTapSpecies: onTapSpecies,
              ),
            ),
          )
        else
          PokemonInfoCard(
            title: 'Evoluciones',
            child: const Text(
              'Este Pokémon no tiene evoluciones.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        const SizedBox(height: 16),
        
        // Sección de formas especiales
        PokemonInfoCard(
          title: 'Formas Especiales',
          child: _buildSpecialFormsSection(formsAsync, megaStonesAsync),
        ),
      ],
    );
  }

  Widget _buildSpecialFormsSection(
    AsyncValue<List<dynamic>> formsAsync,
    AsyncValue<List<Map<String, dynamic>>> megaStonesAsync,
  ) {
    return formsAsync.when(
      data: (forms) {
        // Obtener mega stones si están disponibles
        final megaStones = megaStonesAsync.maybeWhen(
          data: (stones) => stones,
          orElse: () => <Map<String, dynamic>>[],
        );
        
        if (forms.isEmpty && megaStones.isEmpty) {
          return _buildNoFormsMessage();
        }

        return SpecialFormsSection(
          forms: forms.cast(),
          baseName: pokemon.name,
          baseId: pokemon.id,
          megaStones: megaStones,
          onTapForm: onTapForm,
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (error, _) => _buildNoFormsMessage(),
    );
  }

  Widget _buildNoFormsMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Este Pokémon no tiene formas especiales registradas.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white54, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tipos de formas especiales:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildFormTypeInfo(Icons.flash_on, 'Mega Evoluciones', Colors.purple),
              _buildFormTypeInfo(Icons.public, 'Formas Regionales', Colors.teal),
              _buildFormTypeInfo(Icons.cloud, 'Formas Gigantamax', Colors.redAccent),
              _buildFormTypeInfo(Icons.auto_awesome, 'Otras Variantes', Colors.amber),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormTypeInfo(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
