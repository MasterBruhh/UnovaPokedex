import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/pokedex/presentation/pages/home_page.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
        const HomePage(),
      ),
    ],
  );
}
