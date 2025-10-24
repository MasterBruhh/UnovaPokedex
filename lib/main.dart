import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'core/env/env.dart';
import 'core/graphql/graphql_client.dart';
import 'core/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (.env)
  await Env.load();

  // Inicializar GraphQL client
  final client = GraphQLService.initClient();

  runApp(
    ProviderScope(
      child: GraphQLProvider(
        client: client,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Clean Starter',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
