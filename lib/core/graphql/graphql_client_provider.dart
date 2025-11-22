import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../config/app_constants.dart';
import '../config/env_config.dart';

/// Provider para el cliente GraphQL
/// Esto crea una instancia singleton que puede ser accedida en toda la aplicación
final graphqlClientProvider = Provider<ValueNotifier<GraphQLClient>>((ref) {
  return _createGraphQLClient();
});

/// Crea y configura el cliente GraphQL
ValueNotifier<GraphQLClient> _createGraphQLClient() {
  final endpoint =
      EnvConfig.graphqlEndpoint ?? AppConstants.defaultGraphqlEndpoint;

  final httpLink = HttpLink(endpoint);

  Link link = httpLink;

  // Agregar autenticación si se proporciona el token
  final token = EnvConfig.graphqlAuthToken;
  if (token != null && token.isNotEmpty) {
    final authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );
    link = authLink.concat(httpLink);
  }

  final cache = GraphQLCache(store: HiveStore());

  return ValueNotifier(
    GraphQLClient(
      link: link,
      cache: cache,
    ),
  );
}

