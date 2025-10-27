import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// --- Modelos y Enums para Tipos y Regiones ---
enum PokeType { normal, fire, water, electric, grass, ice, fighting, poison, ground, flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy }
enum PokeRegion { kanto, johto, hoenn, sinnoh, unova, kalos, alola, galar, paldea, hisui }

// --- Página Principal de la Pokédex ---
class PokedexListPage extends StatefulWidget {
  const PokedexListPage({super.key});
  @override
  State<PokedexListPage> createState() => _PokedexListPageState();
}

class _PokedexListPageState extends State<PokedexListPage> {
  int _filteredCount = 0;
  final String _query = """
    query KantoPokedex {
      pokemon_v2_pokemon(where: {id: {_lte: 151}}, order_by: {id: asc}) {
        id
        name
        pokemon_v2_pokemontypes {
          pokemon_v2_type {
            name
          }
        }
      }
    }
  """;

  void _openFilterSheet() { /* ... tu código ... */ }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 68;
    return Scaffold(
      backgroundColor: const Color(0xFF6D4C41),
      body: Stack(
        children: [
          const Positioned.fill(child: _WoodGrainBackground()),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Query(
              options: QueryOptions(document: gql(_query)),
              builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
                if (result.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));
                if (result.hasException) return Center(child: Text('Error: ${result.exception}', style: const TextStyle(color: Colors.white)));

                final List pokemons = result.data?['pokemon_v2_pokemon'] ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _filteredCount = pokemons.length);
                });

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: pokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = pokemons[index];
                    final int id = pokemon['id'];
                    final String name = pokemon['name'];
                    final List typesData = pokemon['pokemon_v2_pokemontypes'];
                    final List<PokeType> types = typesData.map((t) {
                      try {
                        return PokeType.values.firstWhere((e) => e.name == t['pokemon_v2_type']['name']);
                      } catch (e) {
                        return PokeType.normal; // Fallback por si el tipo no está en el enum
                      }
                    }).toList();

                    return _PokedexBookSpine(
                      id: id,
                      name: name,
                      types: types,
                      region: PokeRegion.kanto,
                      onTap: () => context.push('/pokedex/${Uri.encodeComponent(name)}'),
                    );
                  },
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
                  const SizedBox(width: 8),
                  _CounterPill(count: _filteredCount),
                  const Spacer(),
                  _FrostedIconButton(icon: Icons.filter_list_rounded, onPressed: _openFilterSheet, tooltip: 'Filtros'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widgets de la UI (Copiados y adaptados de tu archivo) ---
// ... (Todos los widgets como _PokedexBookSpine, _FrostedIconButton, etc. van aquí)
class _PokedexBookSpine extends StatelessWidget {
  const _PokedexBookSpine({ required this.id, required this.name, required this.types, required this.region, required this.onTap });
  final int id;
  final String name;
  final List<PokeType> types;
  final PokeRegion region;
  final VoidCallback onTap;
  String get spriteUrl => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8D6E63), width: 5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _TypeColorBar(types: types),
            const SizedBox(height: 16),
            Hero(tag: 'pokemon-artwork-$id', child: Image.network(spriteUrl, height: 60, fit: BoxFit.contain)),
            Expanded(
              child: RotatedBox(
                quarterTurns: 1,
                child: Center(
                  child: Text(
                    name[0].toUpperCase() + name.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                  ),
                ),
              ),
            ),
            Text('$id', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 4),
            _RegionColorBar(region: region),
          ],
        ),
      ),
    );
  }
}
class _TypeColorBar extends StatelessWidget {
  const _TypeColorBar({required this.types});
  final List<PokeType> types;
  @override
  Widget build(BuildContext context) => SizedBox(height: 10, child: Row(children: types.map((type) => Expanded(child: Container(color: typeColor(type)))).toList()));
}
class _RegionColorBar extends StatelessWidget {
  const _RegionColorBar({required this.region});
  final PokeRegion region;
  @override
  Widget build(BuildContext context) => Container(height: 10, color: regionColor(region));
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
Color regionColor(PokeRegion r) {
  switch (r) {
    case PokeRegion.kanto: return const Color(0xFF9CCC65);
    case PokeRegion.johto: return const Color(0xFFFFCA28);
    case PokeRegion.hoenn: return const Color(0xFF26C6DA);
    case PokeRegion.sinnoh: return const Color(0xFF9575CD);
    case PokeRegion.unova: return const Color(0xFF90A4AE);
    case PokeRegion.kalos: return const Color(0xFF42A5F5);
    case PokeRegion.alola: return const Color(0xFFFF7043);
    case PokeRegion.galar: return const Color(0xFFEC407A);
    case PokeRegion.paldea: return const Color(0xFF66BB6A);
    case PokeRegion.hisui: return const Color(0xFF26A69A);
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
class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    final bg = Colors.black.withOpacity(0.20);
    return Container(
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
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