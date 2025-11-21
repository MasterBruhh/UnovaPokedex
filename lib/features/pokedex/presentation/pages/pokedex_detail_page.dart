import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// ------------------------------------------------------------
/// Tipos y colores
/// ------------------------------------------------------------
enum PokeType {
  normal,
  fire,
  water,
  electric,
  grass,
  ice,
  fighting,
  poison,
  ground,
  flying,
  psychic,
  bug,
  rock,
  ghost,
  dragon,
  dark,
  steel,
  fairy,
}

Color typeColor(PokeType t) {
  switch (t) {
    case PokeType.normal:
      return const Color(0xFFA8A77A);
    case PokeType.fire:
      return const Color(0xFFEE8130);
    case PokeType.water:
      return const Color(0xFF6390F0);
    case PokeType.electric:
      return const Color(0xFFF7D02C);
    case PokeType.grass:
      return const Color(0xFF7AC74C);
    case PokeType.ice:
      return const Color(0xFF96D9D6);
    case PokeType.fighting:
      return const Color(0xFFC22E28);
    case PokeType.poison:
      return const Color(0xFFA33EA1);
    case PokeType.ground:
      return const Color(0xFFE2BF65);
    case PokeType.flying:
      return const Color(0xFFA98FF3);
    case PokeType.psychic:
      return const Color(0xFFF95587);
    case PokeType.bug:
      return const Color(0xFFA6B91A);
    case PokeType.rock:
      return const Color(0xFFB6A136);
    case PokeType.ghost:
      return const Color(0xFF735797);
    case PokeType.dragon:
      return const Color(0xFF6F35FC);
    case PokeType.dark:
      return const Color(0xFF705746);
    case PokeType.steel:
      return const Color(0xFFB7B7CE);
    case PokeType.fairy:
      return const Color(0xFFD685AD);
  }
}

/// ------------------------------------------------------------
/// Evoluciones: modelo y helpers
/// ------------------------------------------------------------
class _Species {
  final int id; // species id
  final String name;
  final int? parentId; // evolves_from_species_id
  const _Species({required this.id, required this.name, this.parentId});
}

Map<int, _Species> speciesMapFromRaw(List raw) {
  final map = <int, _Species>{};
  for (final s in raw) {
    final id = s['id'] as int;
    map[id] = _Species(
      id: id,
      name: s['name'] as String,
      parentId: s['evolves_from_species_id'] as int?,
    );
  }
  return map;
}

List<_Species> childrenOf(int speciesId, Map<int, _Species> map) {
  return map.values.where((n) => n.parentId == speciesId).toList();
}

/// Devuelve la ruta raíz → … → actual (incluye al actual si existe en el mapa).
List<_Species> preChain(int currentId, Map<int, _Species> map) {
  final chain = <_Species>[];
  int? cursor = currentId;
  while (cursor != null) {
    final node = map[cursor];
    if (node == null) break;
    chain.insert(0, node);
    cursor = node.parentId;
  }
  return chain;
}

/// Para cada hijo directo del actual, sigue linealmente mientras cada nodo tenga
/// exactamente 1 hijo; si hay 0 o >1, se detiene esa cadena.
List<List<_Species>> forwardChains(int currentId, Map<int, _Species> map) {
  final result = <List<_Species>>[];
  final firstLevel = childrenOf(currentId, map);
  for (final child in firstLevel) {
    final chain = <_Species>[child];
    var cursor = child;
    while (true) {
      final kids = childrenOf(cursor.id, map);
      if (kids.length == 1) {
        cursor = kids.first;
        chain.add(cursor);
      } else {
        break; // termina si no hay hijos o hay bifurcación
      }
    }
    result.add(chain);
  }
  return result;
}

/// ------------------------------------------------------------
/// Página de Detalle
/// ------------------------------------------------------------
class PokedexDetailPage extends StatelessWidget {
  const PokedexDetailPage({super.key, this.pokemonName, this.pokemonId})
      : assert(pokemonName != null || pokemonId != null, 'Debes proveer un nombre o un ID');

  final String? pokemonName;
  final int? pokemonId;

  // Consulta: añadimos "id" en pokemon_v2_pokemonspecy para usar species_id en el árbol.
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
          id
          pokemon_v2_pokemonspeciesflavortexts(
            where: {language_id: {_eq: 7}}
            order_by: {version_id: desc}
            limit: 1
          ) { flavor_text }

          pokemon_v2_evolutionchain {
            pokemon_v2_pokemonspecies(order_by: {order: asc}) {
              id
              name
              evolves_from_species_id
            }
          }
        }

        pokemon_v2_pokemonmoves(
          where: {pokemon_v2_movelearnmethod: {name: {_eq: "level-up"}}}
          order_by: [{level: asc}, {move_id: asc}]
        ) {
          move_id
          level
          pokemon_v2_move { name }
        }
      }
    }
  ''';

  QueryOptions _buildQueryOptions() {
    final variables = {
      'where': pokemonName != null
          ? {'name': {'_eq': pokemonName}}
          : {'id': {'_eq': pokemonId}},
    };
    return QueryOptions(document: gql(_query), variables: variables);
  }

  String _artworkUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
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
              builder: (result, {refetch, fetchMore}) {
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

                final pokemonList = (result.data?['pokemon_v2_pokemon'] as List?) ?? const [];
                if (pokemonList.isEmpty) {
                  return const Center(child: Text('Pokémon no encontrado', style: TextStyle(color: Colors.white)));
                }
                final pokemon = pokemonList.first as Map<String, dynamic>;

                // Datos básicos (pokemon)
                final int id = pokemon['id'] as int;
                final String name = _titleCase(pokemon['name'] as String);
                final double height = (pokemon['height'] ?? 0).toDouble();
                final double weight = (pokemon['weight'] ?? 0).toDouble();

                // Tipos
                final types = (pokemon['pokemon_v2_pokemontypes'] as List? ?? [])
                    .map((t) => PokeType.values.firstWhere(
                      (e) => e.name == t['pokemon_v2_type']['name'],
                  orElse: () => PokeType.normal,
                ))
                    .toList();

                // Habilidades y stats
                final abilities = pokemon['pokemon_v2_pokemonabilities'] as List? ?? [];
                final stats = (pokemon['pokemon_v2_pokemonstats'] as List?) ?? const [];

                // Especie + descripción (SEGURA, sin .first a ciegas)
                final spec = (pokemon['pokemon_v2_pokemonspecy'] as Map<String, dynamic>?) ?? const {};
                final currentSpeciesId = spec['id'] as int? ?? id; // fallback

                final flavors = (spec['pokemon_v2_pokemonspeciesflavortexts'] as List?) ?? const [];
                String description = '';
                if (flavors.isNotEmpty) {
                  final firstNonEmpty = flavors
                      .cast<Map<String, dynamic>>()
                      .map((f) => (f['flavor_text'] as String?)?.trim() ?? '')
                      .firstWhere((t) => t.isNotEmpty, orElse: () => '');
                  description = firstNonEmpty.replaceAll('\n', ' ').replaceAll('\f', ' ');
                }

                // Evoluciones (usar species_id, NO pokemon.id)
                final speciesRaw = (spec['pokemon_v2_evolutionchain']?['pokemon_v2_pokemonspecies'] as List?) ?? const [];
                final speciesMap = speciesMapFromRaw(speciesRaw);
                final pre = speciesMap.isEmpty ? const <_Species>[] : preChain(currentSpeciesId, speciesMap);
                final forward = speciesMap.isEmpty ? const <List<_Species>>[] : forwardChains(currentSpeciesId, speciesMap);

                // Movimientos: ya vienen ordenados, deduplicamos por move_id
                final rawMoves = (pokemon['pokemon_v2_pokemonmoves'] as List?) ?? const [];
                final seen = <int>{};
                final moves = <Map<String, dynamic>>[];
                for (final m in rawMoves) {
                  final mid = (m['move_id'] as int?) ?? -1;
                  if (mid == -1) continue;
                  if (seen.add(mid)) moves.add((m as Map).cast<String, dynamic>());
                }

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
                                  errorBuilder: (c, e, s) =>
                                  const Icon(Icons.broken_image, color: Colors.white, size: 100),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 12),
                              // Tipos
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                alignment: WrapAlignment.center,
                                children: types
                                    .map((t) => Chip(
                                  label: Text(t.name.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
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
                                  Chip(
                                      label: Text('Altura: ${height.toStringAsFixed(0)}'),
                                      backgroundColor: Colors.white24),
                                  Chip(
                                      label: Text('Peso: ${weight.toStringAsFixed(0)}'),
                                      backgroundColor: Colors.white24),
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
                            final an =
                            ((a['pokemon_v2_ability']?['name'] as String?) ?? '').replaceAll('-', ' ');
                            final hidden = a['is_hidden'] == true;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text('• ${_titleCase(an)}${hidden ? ' (Oculta)' : ''}',
                                  style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Estadísticas
                      _InfoCard(title: 'Estadísticas Base', child: _StatsList(stats: stats)),

                      const SizedBox(height: 16),

                      // Evoluciones (pre + ramas individuales)
                      if (speciesMap.isNotEmpty)
                        _InfoCard(
                          title: 'Evoluciones',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pre.length > 1) ...[
                                const Text('Pre-evoluciones', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 8),
                                _EvolutionChainRow(
                                  chain: pre,
                                  currentId: currentSpeciesId,
                                  spriteUrl: _spriteUrl,
                                  onTapName: (n) => context.push('/pokedex/${Uri.encodeComponent(n)}'),
                                ),
                                const SizedBox(height: 12),
                              ],
                              const Text('Evoluciones posibles', style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (final chain in forward) ...[
                                      _EvolutionChainRow(
                                        chain: [
                                          if (speciesMap[currentSpeciesId] != null) speciesMap[currentSpeciesId]!,
                                          ...chain
                                        ],
                                        currentId: currentSpeciesId,
                                        spriteUrl: _spriteUrl,
                                        onTapName: (n) => context.push('/pokedex/${Uri.encodeComponent(n)}'),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Movimientos por nivel
                      _InfoCard(
                        title: 'Movimientos por Nivel',
                        child: moves.isEmpty
                            ? const Text('No se encontraron movimientos por nivel.',
                            style: TextStyle(color: Colors.white70))
                            : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: moves.length,
                          separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 8),
                          itemBuilder: (context, index) {
                            final m = moves[index];
                            final int level = (m['level'] ?? 0) as int;
                            final String moveName = _titleCase(
                                ((m['pokemon_v2_move']?['name'] as String?) ?? '').replaceAll('-', ' '));
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: SizedBox(
                                width: 56,
                                child: Text('Nv. $level',
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold)),
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
          // Header translúcido
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
                      child: Text(displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
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

/// ------------------------------------------------------------
/// UI auxiliares
/// ------------------------------------------------------------
class _EvolutionChainRow extends StatelessWidget {
  const _EvolutionChainRow({
    required this.chain,
    required this.currentId,
    required this.spriteUrl,
    required this.onTapName,
  });

  final List<_Species> chain;
  final int currentId; // species id actual
  final String Function(int) spriteUrl;
  final void Function(String name) onTapName;

  @override
  Widget build(BuildContext context) {
    if (chain.isEmpty) return const SizedBox.shrink();
    return Row(
      children: List.generate(chain.length * 2 - 1, (i) {
        if (i.isOdd) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: Icon(Icons.arrow_forward, color: Colors.white54, size: 18),
          );
        }
        final node = chain[i ~/ 2];
        final isCurrent = node.id == currentId;
        final display = node.name[0].toUpperCase() + node.name.substring(1);
        return InkWell(
          onTap: () => onTapName(node.name),
          child: Opacity(
            opacity: isCurrent ? 1.0 : 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  spriteUrl(node.id), // usa id de especie (coincide con form por defecto en la mayoría)
                  height: 56,
                  errorBuilder: (c, e, s) => const Icon(Icons.catching_pokemon, color: Colors.white54),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

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
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white30, height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatsList extends StatelessWidget {
  final List stats;
  const _StatsList({required this.stats});

  @override
  Widget build(BuildContext context) {
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

    final list = stats.cast<Map<String, dynamic>>();

    return Column(
      children: order.entries.map((entry) {
        final s = list.firstWhere(
              (e) => (e['pokemon_v2_stat']?['name'] as String?) == entry.key,
          orElse: () => const {},
        );
        if (s.isEmpty) return const SizedBox.shrink();
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
              SizedBox(
                width: 44,
                child: Text('$value',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
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
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: ColoredBox(color: Color(0xFF6D4C41))),
      Positioned.fill(
        child: Opacity(
          opacity: 0.15,
          child: CustomPaint(painter: _WoodGrainPainter()),
        ),
      ),
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