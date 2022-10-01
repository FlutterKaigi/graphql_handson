import 'package:graphql/client.dart';

/// 環境変数を利用する
const gitHubToken = String.fromEnvironment('GITHUB_TOKEN');

final HttpLink httpLink = HttpLink(
  'https://api.github.com/graphql',
);

final AuthLink authLink = AuthLink(
  getToken: () async => 'Bearer $gitHubToken',
);

final Link link = authLink.concat(httpLink);

final client = GraphQLClient(
  cache: GraphQLCache(
    store: HiveStore(),
  ),
  link: link,
);
