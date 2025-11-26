import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import necesario para Hive
import 'app.dart';
import 'core/routing/app_router.dart';
import 'core/audio/audio_controller.dart';
import 'core/config/env_config.dart';
import 'core/graphql/graphql_client_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para la persistencia local (Favoritos)
  // Esto prepara el directorio en el dispositivo para guardar los datos.
  await Hive.initFlutter();

  // Inicializar Hive para caché de GraphQL (de la librería graphql_flutter)
  await initHiveForFlutter();

  // Cargar variables de entorno
  await EnvConfig.load();

  // Inicializar controlador de audio
  await AudioController.instance.init();

  // Construir router
  final router = AppRouter.build();

  // Crear contenedor de provider para obtener el cliente GraphQL
  final container = ProviderContainer();
  final client = container.read(graphqlClientProvider);

  runApp(
    ProviderScope(
      child: MyApp(router: router, client: client),
    ),
  );
}