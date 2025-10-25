import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/presentation/pages/pokeball_splash_page.dart';
import '../../onboarding/presentation/pages/main_menu_page.dart';
import '../../features/pokedex/presentation/pages/pokedex_list_page.dart';
import 'session_manager.dart';

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
    if (route == null) return null;
    final loc = route.settings.name;
    return loc;
  }
}

class AppRouter {
  static GoRouter build({String initialLocation = '/'}) {
    return GoRouter(
      initialLocation: initialLocation,
      observers: [_RouteObserver()],
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const PokeballSplashPage(),
        ),
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
        GoRoute(
          path: '/pokedex',
          name: 'pokedex',
          builder: (context, state) => const PokedexListPage(),
        ),
      ],
    );
  }
}
