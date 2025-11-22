import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gestor de configuración de entorno
class EnvConfig {
  // Constructor privado para prevenir instanciación
  EnvConfig._();

  /// Carga las variables de entorno desde el archivo .env
  /// No lanza excepción si el archivo no existe (útil para CI/CD)
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Fallar silenciosamente si .env no existe
    }
  }

  /// URL del endpoint GraphQL desde entorno o por defecto
  static String? get graphqlEndpoint =>
      dotenv.maybeGet('GRAPHQL_ENDPOINT', fallback: null);

  /// Token de autenticación GraphQL desde entorno
  static String? get graphqlAuthToken =>
      dotenv.maybeGet('GRAPHQL_AUTH_TOKEN', fallback: null);
}

