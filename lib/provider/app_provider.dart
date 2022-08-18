import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    /// 環境変数を利用する
    final String? gitHubToken = dotenv.env['GITHUB_TOKEN'];

    final HttpLink httpLink = HttpLink(
      'https://api.github.com/graphql',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $gitHubToken',
    );

    final Link link = authLink.concat(httpLink);

    final client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}
