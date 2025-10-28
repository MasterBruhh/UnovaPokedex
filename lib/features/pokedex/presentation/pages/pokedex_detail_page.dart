import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// Reutilizamos el enum y colores de tipo
enum PokeType {
  normal, fire, water, electric, grass, ice, fighting, poison, ground, flying,
  psychic, bug, rock, ghost, dragon, dark, steel, fairy
}

Color typeColor(PokeType t) {
  switch (t) {
    case PokeType.normal: return const Color(0xFFA8A77A);
    case PokeType.fire: return const Color(0xFFEE8130);
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

  // Consulta extendida: tipos, stats, habilidades, descripción, evoluciones y movimientos por nivel
  String get _query => r'''
    query PokemonDetails($where: pokemon_v2_pokemon_bool_exp!) {
      pokemon_v2_pokemon(where: $where, limit: 1) {
        id
        name
        height
        weight

        pokemon_v2_pokemontypes {
          pokemon_v2_type { name }
        }

        pokemon_v2_pokemonabilities {
          is_hidden
          pokemon_v2_ability { name }
        }

        pokemon_v2_pokemonstats {
          base_stat
          pokemon_v2_stat { name }
        }

        pokemon_v2_pokemonspecy {
          pokemon_v2_pokemonspeciesflavortexts(
            where: {language_id: {_eq: 7}}
            order_by: {version_id: desc}
            limit: 1
          ) {
            flavor_text
          }
          pokemon_v2_evolutionchain {
            pokemon_v2_pokemonspecies(order_by: {order: asc}) {
              id
              name
            }
          }
        }

        pokemon_v2_pokemonmoves(
        where: {pokemon_v2_movelearnmethod: {name: {_eq: "level-up"}}}
        distinct_on: [move_id]
        order_by: [{move_id: asc}, {level: asc}]
      ) {
        move_id
        level
        pokemon_v2_move { name }
      }
      }
    }
  ''';

  QueryOptions _buildQueryOptions() {
    final Map<String, dynamic> variables = {
      'where': pokemonName != null
          ? {'name': {'_eq': pokemonName}}
          : {'id': {'_eq': pokemonId}},
    };
    return QueryOptions(document: gql(_query), variables: variables);
  }

  String _artworkUrl(int id) => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  String _spriteUrl(int id) => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  String _titleCase(String s) {
    final clean = s.replaceAll('-', ' ');
    if (clean.isEmpty) return clean;
    return clean[0].toUpperCase() + clean.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 68;
    final displayName = pokemonName != null ? _titleCase(pokemonName!) : 'Pokémon';

    return Scaffold(
      backgroundColor: const Color(0xFF6D4C41),
      body: Stack(
        children: [
          const Positioned.fill(child: _WoodGrainBackground()),

          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Query(
              options: _buildQueryOptions(),
              builder: (QueryResult result, {refetch, fetchMore}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (result.hasException) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: ${result.exception}', style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }

                final pokemon = (result.data?['pokemon_v2_pokemon'] as List?)?.first;
                if (pokemon == null) {
                  return const Center(child: Text('Pokémon no encontrado', style: TextStyle(color: Colors.white)));
                }

                // Parseo de datos
                final int id = pokemon['id'];
                final String name = _titleCase(pokemon['name']);
                final double height = (pokemon['height'] ?? 0).toDouble();
                final double weight = (pokemon['weight'] ?? 0).toDouble();

                final List typesData = pokemon['pokemon_v2_pokemontypes'] ?? [];
                final List<PokeType> types = typesData.map((t) {
                  final n = (t['pokemon_v2_type']['name'] as String);
                  return PokeType.values.firstWhere(
                        (e) => e.name == n,
                    orElse: () => PokeType.normal,
                  );
                }).toList();

                final List abilities = pokemon['pokemon_v2_pokemonabilities'] ?? [];
                final List stats = pokemon['pokemon_v2_pokemonstats'] ?? [];

                final flavorText = (pokemon['pokemon_v2_pokemonspecy']?['pokemon_v2_pokemonspeciesflavortexts'] as List?)
                    ?.first?['flavor_text'] as String? ??
                    '';
                final description = flavorText.replaceAll('\n', ' ').replaceAll('\f', ' ');

                final List evolutions = pokemon['pokemon_v2_pokemonspecy']?['pokemon_v2_evolutionchain']?['pokemon_v2_pokemonspecies'] ?? [];
                final List moves = pokemon['pokemon_v2_pokemonmoves'] ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tarjeta principal
                      Card(
                        color: Colors.white.withOpacity(0.15),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Hero(
                                tag: 'pokemon-artwork-$id',
                                child: Image.network(
                                  _artworkUrl(id),
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white, size: 100),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 12),
                              // Tipos
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                alignment: WrapAlignment.center,
                                children: types
                                    .map((t) => Chip(
                                  label: Text(t.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  backgroundColor: typeColor(t),
                                ))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              // Altura / Peso
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  Chip(label: Text('Altura: ${height.toStringAsFixed(0)}'), backgroundColor: Colors.white24),
                                  Chip(label: Text('Peso: ${weight.toStringAsFixed(0)}'), backgroundColor: Colors.white24),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Descripción
                      if (description.isNotEmpty)
                        _InfoCard(
                          title: 'Descripción',
                          child: Text(description, style: const TextStyle(color: Colors.white, height: 1.5)),
                        ),

                      const SizedBox(height: 16),

                      // Habilidades
                      _InfoCard(
                        title: 'Habilidades',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: abilities.map((a) {
                            final String an = (a['pokemon_v2_ability']['name'] as String).replaceAll('-', ' ');
                            final bool hidden = a['is_hidden'] == true;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '• ${_titleCase(an)}${hidden ? ' (Oculta)' : ''}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Estadísticas
                      _InfoCard(
                        title: 'Estadísticas Base',
                        child: _StatsList(stats: stats),
                      ),

                      const SizedBox(height: 16),

                      // Evoluciones
                      if (evolutions.length > 1)
                        _InfoCard(
                          title: 'Evoluciones',
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(evolutions.length * 2 - 1, (i) {
                                if (i.isOdd) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.arrow_forward, color: Colors.white54),
                                  );
                                }
                                final evo = evolutions[i ~/ 2];
                                final int evoId = evo['id'] as int;
                                final String evoName = _titleCase(evo['name'] as String);
                                final bool isCurrent = evoId == id;
                                return InkWell(
                                  onTap: () {
                                    // navegar al detalle de la evolución
                                    context.push('/pokedex/${Uri.encodeComponent(evo['name'] as String)}');
                                  },
                                  child: Opacity(
                                    opacity: isCurrent ? 1.0 : 0.75,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(_spriteUrl(evoId), height: 64, errorBuilder: (c,e,s)=>const Icon(Icons.catching_pokemon, color: Colors.white54)),
                                        const SizedBox(height: 6),
                                        Text(evoName, style: TextStyle(color: Colors.white, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Movimientos por nivel
                      _InfoCard(
                        title: 'Movimientos por Nivel',
                        child: moves.isEmpty
                            ? const Text('No se encontraron movimientos por nivel.', style: TextStyle(color: Colors.white70))
                            : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: moves.length,
                          separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 8),
                          itemBuilder: (context, index) {
                            final m = moves[index];
                            final int level = (m['level'] ?? 0) as int;
                            final String moveName = _titleCase((m['pokemon_v2_move']['name'] as String).replaceAll('-', ' '));
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 56,
                                alignment: Alignment.centerLeft,
                                child: Text('Nv. $level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(moveName, style: const TextStyle(color: Colors.white)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Header "frosty" como en la lista
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

// Tarjeta genérica de sección
class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.10),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white30, height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

// Barra de stats
class _StatsList extends StatelessWidget {
  final List stats;
  const _StatsList({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Orden canónico y etiqueta amigable
    const order = <String, String>{
      'hp': 'HP',
      'attack': 'Ataque',
      'defense': 'Defensa',
      'special-attack': 'At. Esp.',
      'special-defense': 'Def. Esp.',
      'speed': 'Velocidad',
    };

    int maxStat = 1;
    for (final s in stats) {
      final v = (s['base_stat'] ?? 0) as int;
      if (v > maxStat) maxStat = v;
    }

    return Column(
      children: order.entries.map((entry) {
        final s = stats.firstWhere(
              (e) => (e['pokemon_v2_stat']['name'] as String) == entry.key,
          orElse: () => null,
        );
        if (s == null) return const SizedBox.shrink();
        final int value = (s['base_stat'] ?? 0) as int;
        final ratio = (value / maxStat).clamp(0.0, 1.0);
        final barColor = value > maxStat * 0.6
            ? Colors.green
            : value > maxStat * 0.3
            ? Colors.yellow
            : Colors.red;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(width: 92, child: Text(entry.value, style: const TextStyle(color: Colors.white70))),
              Expanded(
                child: LinearProgressIndicator(
                  value: ratio,
                  color: barColor,
                  backgroundColor: Colors.white12,
                  minHeight: 10,
                ),
              ),
              SizedBox(width: 44, child: Text('$value', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Botón frosty reutilizado
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

// Fondo madera
class _WoodGrainBackground extends StatelessWidget {
  const _WoodGrainBackground();
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: ColoredBox(color: Color(0xFF6D4C41))),
      Positioned.fill(child: Opacity(opacity: 0.15, child: CustomPaint(painter: _WoodGrainPainter()))),
    ],
  );
}

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    for (double x = -20; x < size.width + 20; x += 60) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..cubicTo(x + 15, size.height * 0.25, x - 10, size.height * 0.6, x + 10, size.height)
          ..lineTo(x + 20, size.height)
          ..cubicTo(x + 35, size.height * 0.65, x + 10, size.height * 0.3, x + 30, 0),
        paint..color = Colors.brown.shade300,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}