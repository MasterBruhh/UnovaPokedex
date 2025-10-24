import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    // Intenta cargar .env; si no existe, no falla el arranque (útil en CI o primeras corridas)
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // noop
    }
  }

  static String? get graphqlEndpoint =>
      dotenv.maybeGet('GRAPHQL_ENDPOINT', fallback: null);

  static String? get graphqlAuthToken =>
      dotenv.maybeGet('GRAPHQL_AUTH_TOKEN', fallback: null);
}
