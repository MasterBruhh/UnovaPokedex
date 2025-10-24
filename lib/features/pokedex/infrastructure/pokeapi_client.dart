import 'dart:convert';
import 'package:http/http.dart' as http;

/// Cliente mínimo para PokeAPI (REST).
class PokeApiClient {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  /// Fetch simple: devuelve el nombre y el id del Pokémon solicitado.
  static Future<Map<String, dynamic>> fetchPokemonBasic(String nameOrId) async {
    final url = Uri.parse('$baseUrl/pokemon/$nameOrId');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('PokeAPI error ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return {
      'id': data['id'],
      'name': data['name'],
    };
  }
}
