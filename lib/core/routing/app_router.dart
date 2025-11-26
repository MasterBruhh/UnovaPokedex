import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/pokeball_splash_page.dart';
import '../../features/onboarding/presentation/pages/main_menu_page.dart';
import '../../features/pokedex/presentation/pages/favorites_page.dart';
import '../../features/pokedex/presentation/pages/pokedex_list_page.dart';
import '../../features/pokedex/presentation/pages/pokedex_detail_page.dart';
import 'session_manager.dart';

/// Observador de rutas para rastrear la navegación
class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name ?? _nameFromRoute(route);
    if (name != null) {
      SessionManager.setLastRoute(name);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final name = newRoute?.settings.name ?? _nameFromRoute(newRoute);
    if (name != null) {
      SessionManager.setLastRoute(name);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = previousRoute?.settings.name ?? _nameFromRoute(previousRoute);
    if (name != null) {
      SessionManager.setLastRoute(name);
    }
    super.didPop(route, previousRoute);
  }

  String? _nameFromRoute(Route<dynamic>? route) {
    return route?.settings.name;
  }
}

/// Configuración del enrutador de la aplicación
class AppRouter {
  // Constructor privado para prevenir instanciación
  AppRouter._();

  /// Construye y devuelve la instancia de GoRouter
  static GoRouter build({String initialLocation = '/'}) {
    return GoRouter(
      initialLocation: initialLocation,
      observers: [_RouteObserver()],
      routes: <RouteBase>[
        // Pantalla de splash
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const PokeballSplashPage(),
        ),

        // Menú principal
        GoRoute(
          path: '/menu',
          name: 'menu',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            name: 'menu',
            child: const MainMenuPage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              );
              return FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.5, end: 1.0).animate(curved),
                  child: child,
                ),
              );
            },
          ),
        ),

        // Lista de pokédex
        GoRoute(
          path: '/pokedex',
          name: 'pokedex',
          builder: (context, state) => const PokedexListPage(),
        ),

        // Detalle de pokédex por nombre
        GoRoute(
          path: '/pokedex/:name',
          name: 'pokedex_detail',
          builder: (context, state) {
            final pokemonName = state.pathParameters['name'];
            return PokedexDetailPage(pokemonName: pokemonName);
          },
        ),

        // --- PASO 5: Ruta de Favoritos ---
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          builder: (context, state) => const FavoritesPage(),
        ),
        // -------------------------------
      ],
    );
  }
}