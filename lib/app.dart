import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/theme/app_theme.dart';

/// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.router,
    required this.client,
  });

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

