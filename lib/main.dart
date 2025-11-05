import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/audio/audio_controller.dart';
import 'core/env/env.dart';
import 'core/graphql/graphql_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHiveForFlutter();

  // Cargar variables de entorno (si existen)
  await Env.load();

  // Construye el cliente
  final client = GraphQLService.initClient();

  await AudioController.instance.init();

  final router = AppRouter.build();

  runApp(ProviderScope(child: MyApp(router: router, client: client)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router, required this.client});

  final RouterConfig<Object> router;
  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp.router(
        title: 'Unova Pokedex',
        theme: AppTheme.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}