import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- CAMBIO 1
import 'package:pokedex/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';

import 'package:pokedex/features/trivia/presentation/providers/trivia_provider.dart';

/// Widget principal de la aplicación
// 3. CAMBIAR A ConsumerWidget
class MyApp extends ConsumerWidget { // <--- CAMBIO 3: De StatelessWidget a ConsumerWidget
  const MyApp({
    super.key,
    required this.router,
    required this.client,
  });

  final RouterConfig<Object> router;
  final ValueNotifier<GraphQLClient> client;

  @override
  // 4. AGREGAR WidgetRef ref
  Widget build(BuildContext context, WidgetRef ref) { // <--- CAMBIO 4: Agregar 'ref'

    // 5. ESCUCHAR EL PROVIDER DEL IDIOMA
    final locale = ref.watch(localeProvider); // <--- CAMBIO 5: Obtener el idioma actual

    return GraphQLProvider(
      client: client,
      child: MaterialApp.router(
        title: 'Unova Pokedex',
        theme: AppTheme.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,

        // 6. CONECTAR EL LOCALE
        locale: locale, // <--- CAMBIO 6: Asignar la variable aquí

        // Configuración de Internacionalización (i18n)
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
      ),
    );
  }
}