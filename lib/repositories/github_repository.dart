import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_handson/features.dart';
import 'package:graphql_handson/graphql/query.dart';
import 'package:graphql_handson/plugins/graphql_client.dart';

// ToDo: model を作成する
Future<List<dynamic>?> fetchRepositories() async {
  var result = await client.query(
    QueryOptions(
      document:
          gql((showRepository && !showIssue) ? repositoriesQuery : issuesQuery),
    ),
  );

  List? items = (showRepository && !showIssue)
      ? (result.data?['viewer']?['repositories']?['nodes'])
      : (result.data?['viewer']?['repository']?['issues']?['nodes']);

  return items;
}
