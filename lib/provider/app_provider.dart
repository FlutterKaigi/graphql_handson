import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppProvider extends HookConsumerWidget {
  AppProvider({super.key, required this.child});

  Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 環境変数を利用する
    const gitHubToken = String.fromEnvironment('GITHUB_TOKEN');

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
