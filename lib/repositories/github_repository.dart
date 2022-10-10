import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_handson/features.dart';
import 'package:graphql_handson/graphql/query.dart';
import 'package:graphql_handson/model/repository.dart';
import 'package:graphql_handson/plugins/graphql_client.dart';

Future<List<Repository>?> fetchRepositories() async {
  var response = await client.query(
    QueryOptions(
      document: gql(repositoriesQuery),
    ),
  );
  final List<dynamic>? results =
      response.data?['viewer']?['repositories']?['nodes'];
  final List<Repository> repositoryList =
      results!.map((dynamic item) => Repository.fromJson(item)).toList();
  return repositoryList;
}

Future<List<dynamic>?> fetchIssues() async {
  var result = await client.query(
    QueryOptions(
      document:
          gql((showRepository && !showIssue) ? repositoriesQuery : issuesQuery),
    ),
  );

  List? items = (showRepository && !showIssue)
      ? (result.data?['viewer']?['repositories']?['nodes'])
      : (result.data?['repository']?['issues']?['nodes']);

  return items;
}
