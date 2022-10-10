import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_handson/graphql/query.dart';
import 'package:graphql_handson/model/issue.dart';
import 'package:graphql_handson/model/repository.dart';
import 'package:graphql_handson/plugins/graphql_client.dart';

// リポジトリ一覧の取得
Future<List<Repository>?> fetchRepositories() async {
  var repositoryResponse = await client.query(
    QueryOptions(
      document: gql(repositoriesQuery),
    ),
  );
  final List<dynamic>? results =
      repositoryResponse.data?['viewer']?['repositories']?['nodes'];
  final List<Repository> repositoryList =
      results!.map((dynamic item) => Repository.fromJson(item)).toList();
  return repositoryList;
}

// Issue一覧の取得
Future<List<Issue>?> fetchIssues() async {
  var issueResponse = await client.query(
    QueryOptions(
      document: gql(issuesQuery),
    ),
  );

  final List<dynamic>? results =
      issueResponse.data?['repository']?['issues']?['nodes'];
  final List<Issue> issueList =
      results!.map((dynamic item) => Issue.fromJson(item)).toList();
  return issueList;
}
