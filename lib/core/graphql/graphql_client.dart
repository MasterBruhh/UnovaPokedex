import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../env/env.dart';

class GraphQLService {
  // Inicializa un GraphQLClient con HttpLink y AuthLink opcional (Bearer).
  static ValueNotifier<GraphQLClient> initClient() {
    final httpLink = HttpLink(
      Env.graphqlEndpoint ?? 'https://beta.pokeapi.co/graphql/v1beta2',
    );

    Link link = httpLink;

    final token = Env.graphqlAuthToken;
    if (token != null && token.isNotEmpty) {
      final authLink = AuthLink(
        // Header estándar para bearer token
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
}
