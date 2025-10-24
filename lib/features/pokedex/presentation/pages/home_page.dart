import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _runHealthQuery(BuildContext context) async {
    // Query mínima para validar que el cliente compila y ejecuta algo
    final client = GraphQLProvider.of(context).value;
    final result = await client.query(
      QueryOptions(
        document: gql('query { __typename }'),
      ),
    );

    // Log en consola y feedback visual
    // (En un backend real podrías usar una query de "health" si existe)
    // Comentarios en español per tu preferencia
    debugPrint('GraphQL health result: ${result.data} / hasException=${result.hasException}');
    if (context.mounted) {
      final text = result.hasException
          ? 'GraphQL error: ${result.exception}'
          : 'GraphQL OK: ${result.data}';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokedex')),
      body: const Center(
        child: Text('Project bootstrapped: Riverpod + GoRouter + GraphQL ready'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _runHealthQuery(context),
        tooltip: 'Test GraphQL',
        child: const Icon(Icons.health_and_safety),
      ),
    );
  }
}
