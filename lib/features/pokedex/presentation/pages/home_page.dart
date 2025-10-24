import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../application/pokemon_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // función de salud de GraphQL
  Future<void> _runHealthQuery(BuildContext context) async {
    // Query mínima para validar que el cliente compila y ejecuta algo
    final client = GraphQLProvider.of(context).value;
    final result = await client.query(
      QueryOptions(
        document: gql('query { __typename }'),
      ),
    );

    // Log en consola y feedback visual
    debugPrint(
      'GraphQL health result: ${result.data} / hasException=${result.hasException}',
    );

    final text = result.hasException
        ? 'GraphQL error: ${result.exception}'
        : 'GraphQL OK: ${result.data}';

    // Mostramos un SnackBar con el resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ditto = ref.watch(dittoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pokedex')),
      body: Center(
        child: ditto.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
          data: (data) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PokeAPI test'),
              const SizedBox(height: 8),
              Text('Name: ${data['name']}'),
              Text('ID: ${data['id']}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dittoProvider),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _runHealthQuery(context),
        tooltip: 'Test GraphQL',
        child: const Icon(Icons.health_and_safety),
      ),
    );
  }
}
