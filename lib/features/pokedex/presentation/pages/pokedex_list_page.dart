import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// --- Modelos y Enums (sin cambios) ---
enum PokeType { normal, fire, water, electric, grass, ice, fighting, poison, ground, flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy }
enum PokeRegion { kanto, johto, hoenn, sinnoh, unova, kalos, alola, galar, paldea, hisui }

// --- Página Principal de la Pokédex (con filtros) ---

class PokedexListPage extends StatefulWidget {
  const PokedexListPage({super.key});
  @override
  State<PokedexListPage> createState() => _PokedexListPageState();
}

class _PokedexListPageState extends State<PokedexListPage> {
  // --- Estado para los filtros ---
  String _searchText = '';
  final Set<PokeType> _selectedTypes = {};
  final Set<PokeRegion> _selectedRegions = {}; //regiones seleccionadas

  // --- Lista completa y lista filtrada ---
  List _allPokemons = [];
  List _filteredPokemons = [];

  // La consulta GraphQL no cambia
  final String _query = """
    query KantoPokedex {
      pokemon_v2_pokemon(where: {id: {_lte: 1025}}, order_by: {id: asc}) {
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

  @override
  void initState() {
    super.initState();
    // Inicializamos la lista filtrada como vacía al principio
    _filteredPokemons = [];
  }

  /// Lógica central para aplicar los filtros sobre la lista de Pokémon.
  void _applyFilters() {
    List filtered = List.from(_allPokemons);

    // 1. Filtrar por texto de búsqueda
    if (_searchText.isNotEmpty) {
      filtered = filtered.where((p) => (p['name'] as String).contains(_searchText.toLowerCase())).toList();
    }

    // 2. Filtrar por tipos seleccionados
    if (_selectedTypes.isNotEmpty) {
      // Los Pokémon tienen como máximo 2 tipos. Si seleccionas más de 2, no habrá coincidencias.
      if (_selectedTypes.length > 2) {
        filtered = <dynamic>[];
      } else {
        filtered = filtered.where((p) {
          // Construimos el set de tipos del Pokémon
          final Set<PokeType> pokemonTypes = (p['pokemon_v2_pokemontypes'] as List)
              .map((t) => t['pokemon_v2_type']['name'] as String)
              .map((name) => PokeType.values.firstWhere(
                (e) => e.name == name,
            orElse: () => PokeType.normal, // Los nombres de PokeAPI coinciden con el enum, así que este orElse no debería activarse.
          ))
              .toSet();

          // AND: el Pokémon debe contener TODOS los tipos seleccionados
          final bool containsAllSelected = _selectedTypes.every(pokemonTypes.contains);

          return containsAllSelected;
        }).toList();
      }
    }

    // 3. Filtrar por regiones seleccionadas
    if (_selectedRegions.isNotEmpty) {
      filtered = filtered.where((p) {
        final int id = p['id'] as int;
        final region = regionForDexId(id);
        return _selectedRegions.contains(region);
      }).toList();
    }

    setState(() {
      _filteredPokemons = filtered;
    });
  }

  /// Abre el panel de filtros.
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el sheet sea más alto
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        // Usamos StatefulBuilder para que el contenido del sheet pueda actualizar su propio estado
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                runSpacing: 16,
                children: [
                  const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // Campo de búsqueda
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Buscar por nombre...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  // Chips de tipos
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: PokeType.values.map((type) {
                      final isSelected = _selectedTypes.contains(type);
                      return FilterChip(
                        label: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                        selected: isSelected,
                        onSelected: (selected) {
                          // Actualiza tanto el estado del sheet como el de la página principal
                          setSheetState(() {
                            if (selected) {
                              _selectedTypes.add(type);
                            } else {
                              _selectedTypes.remove(type);
                            }
                          });
                          _applyFilters();
                        },
                        selectedColor: typeColor(type).withValues(alpha: 0.8),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 8),
                  const Text('Regiones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  // Chips de regiones
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: PokeRegion.values.map((region) {
                      final isSelected = _selectedRegions.contains(region);
                      return FilterChip(
                        label: Text(region.name[0].toUpperCase() + region.name.substring(1)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              _selectedRegions.add(region);
                            } else {
                              _selectedRegions.remove(region);
                            }
                          });
                          _applyFilters();
                        },
                        selectedColor: regionColor(region).withValues(alpha: 0.85),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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

                // Guardamos la lista completa la primera vez que llega
                if (_allPokemons.isEmpty && result.data?['pokemon_v2_pokemon'] != null) {
                  _allPokemons = result.data!['pokemon_v2_pokemon'];
                  // Actualización de filtros fuera del ciclo de build del Query
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _applyFilters();
                  });
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: _filteredPokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = _filteredPokemons[index];
                    final int id = pokemon['id'];
                    final String name = pokemon['name'];
                    final List typesData = pokemon['pokemon_v2_pokemontypes'];
                    final List<PokeType> types = typesData.map((t) => PokeType.values.firstWhere((e) => e.name == t['pokemon_v2_type']['name'], orElse: () => PokeType.normal)).toList();
                    final region = regionForDexId(id);
                    return _PokedexBookSpine(
                      id: id,
                      name: name,
                      types: types,
                      region: region,
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
                  _CounterPill(count: _filteredPokemons.length), // El contador ahora usa la lista filtrada
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
PokeRegion regionForDexId(int id) {
  if (id <= 151) return PokeRegion.kanto;          // Gen I
  if (id <= 251) return PokeRegion.johto;          // Gen II
  if (id <= 386) return PokeRegion.hoenn;          // Gen III
  if (id <= 493) return PokeRegion.sinnoh;         // Gen IV
  if (id <= 649) return PokeRegion.unova;          // Gen V
  if (id <= 721) return PokeRegion.kalos;          // Gen VI
  if (id <= 809) return PokeRegion.alola;          // Gen VII
  if (id <= 898) return PokeRegion.galar;          // Gen VIII (base)
  if (id <= 905) return PokeRegion.hisui;          // Gen VIII (Hisui: 899–905)
  // Resto Gen IX (Paldea)
  return PokeRegion.paldea;
}

// --- Widgets de la UI
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
    case PokeRegion.galar:  return const Color(0xFFEC407A);
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
    final bg = Colors.black.withValues(alpha: 0.20);
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
    final bg = Colors.black.withValues(alpha: 0.20);
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