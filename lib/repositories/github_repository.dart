import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_handson/graphql/mutation.dart';
import 'package:graphql_handson/graphql/query.dart';
import 'package:graphql_handson/model/issue.dart';
import 'package:graphql_handson/model/repository.dart';
import 'package:graphql_handson/plugins/graphql_client.dart';

// リポジトリ一覧の取得
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

// Issue一覧の取得
Future<List<Issue>?> fetchIssues() async {
  var response = await client.query(
    QueryOptions(
      document: gql(issuesQuery),
    ),
  );

  final List<dynamic>? results =
      response.data?['repository']?['issues']?['nodes'];
  final List<Issue> issueList =
      results!.map((dynamic item) => Issue.fromJson(item)).toList();
  return issueList;
}

// Issueの作成
Future<void> createIssue({required String title, required String body}) async {
  final MutationOptions options = MutationOptions(
    document: gql(issueMutation),
    variables: <String, dynamic>{
      'titleText': title,
      'bodyText': body,
    },
  );

  final QueryResult result = await client.mutate(options);
  if (result.hasException) {
    log(result.exception.toString());
    return;
  }
}
