import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/audio/audio_controller.dart';
import 'core/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  await AudioController.instance.init();

  // Siempre comienza en la pantalla de bienvenida para lanzamientos en frío;
  // la reanudación en segundo plano no volverá a ejecutar main.
  final router = AppRouter.build();

  runApp(ProviderScope(child: MyApp(router: router)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Unova Pokedex',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
