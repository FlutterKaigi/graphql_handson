/// リポジトリ一覧を取得する
String repositoriesQuery = """
  query {
    viewer {
      login
      repositories(last: 10) {
        nodes {
          id
          name
          description
          url
          updatedAt
        }
      }
    }
  }
""";

/// イシュー一覧を取得する
/// 個別にユーザ名とリポジトリ名を設定する
String issuesQuery = """
  query {
    viewer {
      login
    }
    repository(name: "_graphql_handson", owner: "FlutterKaigi") {
      description
      createdAt
      name
      issues(
        states: OPEN
        first: 100
        orderBy: { field: CREATED_AT, direction: DESC }
      ) {
        nodes {
          id
          body
          updatedAt
          title
          url
        }
      }
    }
  }
""";
