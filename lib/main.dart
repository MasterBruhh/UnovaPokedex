import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart'; // <-- 1. Importa GraphQL
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/audio/audio_controller.dart';
import 'core/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Configuración de GraphQL ---
  // 2. Inicializa la caché local para GraphQL (es importante hacerlo al principio)
  await initHiveForFlutter();

  // 3. Define a qué URL de la API nos vamos a conectar
  final HttpLink httpLink = HttpLink(
    'https://beta.pokeapi.co/graphql/v1beta',
  );

  // 4. Crea el cliente de GraphQL que usará toda la app
  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
  // --- Fin de la configuración de GraphQL ---

  // El resto de tus inicializaciones
  await Env.load();
  await AudioController.instance.init();

  final router = AppRouter.build();

  // 5. Pasa el cliente a MyApp para que lo provea al resto de widgets
  runApp(ProviderScope(child: MyApp(router: router, client: client)));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.router,
    required this.client, // <-- 6. MyApp ahora recibe el cliente
  });

  final RouterConfig<Object> router;
  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    // 7. Envuelve tu MaterialApp con el GraphQLProvider
    return GraphQLProvider(
      client: client,
      child: MaterialApp.router(
        title: 'Unova Pokedex',
        theme: AppTheme.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false, // Opcional: para quitar el banner de "DEBUG"
      ),
    );
  }
}