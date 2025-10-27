import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// --- Widgets de Estilo (reutilizados) ---
enum PokeType { normal, fire, water, electric, grass, ice, fighting, poison, ground, flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy }
Color typeColor(PokeType t) {
  switch (t) {
    case PokeType.normal: return const Color(0xFFA8A77A);
    case PokeType.fire: return const Color(0xFFEE8130);
  // ... (el resto de tus colores)
    case PokeType.water: return const Color(0xFF6390F0);
    case PokeType.electric: return const Color(0xFFF7D02C);
    case PokeType.grass: return const Color(0xFF7AC74C);
    case PokeType.ice: return const Color(0xFF96D9D6);
    case PokeType.fighting: return const Color(0xFFC22E28);
    case PokeType.poison: return const Color(0xFFA33EA1);
    case PokeType.ground: return const Color(0xFFE2BF65);
    case PokeType.flying: return const Color(0xFFA98FF3);
    case PokeType.psychic: return const Color(0xFFF95587);
    case PokeType.bug: return const Color(0xFFA6B91A);
    case PokeType.rock: return const Color(0xFFB6A136);
    case PokeType.ghost: return const Color(0xFF735797);
    case PokeType.dragon: return const Color(0xFF6F35FC);
    case PokeType.dark: return const Color(0xFF705746);
    case PokeType.steel: return const Color(0xFFB7B7CE);
    case PokeType.fairy: return const Color(0xFFD685AD);
  }
}

class PokedexDetailPage extends StatelessWidget {
  const PokedexDetailPage({super.key, this.pokemonName, this.pokemonId})
      : assert(pokemonName != null || pokemonId != null, 'Debes proveer un nombre o un ID');

  final String? pokemonName;
  final int? pokemonId;

  // --- ¡AQUÍ ESTÁ EL CAMBIO PRINCIPAL! ---
  /// Construye la consulta y las variables dinámicamente.
  QueryOptions _buildQueryOptions() {
    // Parte base de la consulta
    const String queryDocument = r'''
      query PokemonDetails($where: pokemon_v2_pokemon_bool_exp!) {
        pokemon_v2_pokemon(where: $where, limit: 1) {
          id
          name
          height
          weight
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
          pokemon_v2_pokemonabilities {
            pokemon_v2_ability {
              name
            }
          }
          pokemon_v2_pokemonstats {
            base_stat
            pokemon_v2_stat {
              name
            }
          }
        }
      }
    ''';

    // Construye la cláusula 'where' y las variables según lo que tengamos.
    final Map<String, dynamic> variables;
    if (pokemonName != null) {
      variables = {
        'where': {
          'name': {'_eq': pokemonName}
        }
      };
    } else {
      variables = {
        'where': {
          'id': {'_eq': pokemonId}
        }
      };
    }

    return QueryOptions(
      document: gql(queryDocument),
      variables: variables,
    );
  }

  String _artworkUrl(int id) => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 68;
    final displayName = pokemonName != null ? (pokemonName![0].toUpperCase() + pokemonName!.substring(1)) : 'Pokémon';

    return Scaffold(
      backgroundColor: const Color(0xFF6D4C41),
      body: Stack(
        children: [
          const Positioned.fill(child: _WoodGrainBackground()),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Query(
              options: _buildQueryOptions(), // <-- Usamos la función que construye las opciones
              builder: (QueryResult result, { refetch, fetchMore }) {
                if (result.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));
                if (result.hasException) return Center(child: Text('Error: ${result.exception}', style: const TextStyle(color: Colors.white)));

                final pokemon = (result.data?['pokemon_v2_pokemon'] as List?)?.first;
                if (pokemon == null) return const Center(child: Text('Pokémon no encontrado', style: TextStyle(color: Colors.white)));

                final int id = pokemon['id'];
                final String name = pokemon['name'];
                final List typesData = pokemon['pokemon_v2_pokemontypes'];
                final List<PokeType> types = typesData.map((t) {
                  try {
                    return PokeType.values.firstWhere((e) => e.name == t['pokemon_v2_type']['name']);
                  } catch (e) {
                    return PokeType.normal;
                  }
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white.withOpacity(0.15),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Hero(
                                tag: 'pokemon-artwork-$id',
                                child: Image.network(_artworkUrl(id), height: 200, fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 16),
                              Text(name[0].toUpperCase() + name.substring(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 8),
                              _TypeChipBar(types: types),
                            ],
                          ),
                        ),
                      ),
                      // Aquí puedes añadir más tarjetas para estadísticas, etc.
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _FrostedIconButton(icon: Icons.arrow_back, onPressed: () => context.pop(), tooltip: 'Volver'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: ShapeDecoration(color: Colors.black.withOpacity(0.2), shape: const StadiumBorder()),
                      child: Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widgets de Estilo (reutilizados) ---
class _TypeChipBar extends StatelessWidget {
  const _TypeChipBar({required this.types});
  final List<PokeType> types;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 4,
    alignment: WrapAlignment.center,
    children: types.map((type) => Chip(
      label: Text(type.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: typeColor(type),
      padding: const EdgeInsets.symmetric(horizontal: 10),
    )).toList(),
  );
}
class _FrostedIconButton extends StatelessWidget {
  const _FrostedIconButton({required this.icon, required this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  @override
  Widget build(BuildContext context) {
    final bg = Colors.black.withOpacity(0.20);
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Container(
            decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
class _WoodGrainBackground extends StatelessWidget {
  const _WoodGrainBackground();
  @override
  Widget build(BuildContext context) => Stack(children: [ const Positioned.fill(child: ColoredBox(color: Color(0xFF6D4C41))), Positioned.fill(child: Opacity(opacity: 0.15, child: CustomPaint(painter: _WoodGrainPainter())))]);
}
class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.brown.shade200..style = PaintingStyle.stroke..strokeWidth = 12;
    for (double x = -20; x < size.width + 20; x += 60) {
      canvas.drawPath(Path()..moveTo(x, 0)..cubicTo(x + 15, size.height * 0.25, x - 10, size.height * 0.6, x + 10, size.height)..lineTo(x + 20, size.height)..cubicTo(x + 35, size.height * 0.65, x + 10, size.height * 0.3, x + 30, 0), paint..color = Colors.brown.shade300);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}