/// アカウント ID をフェッチする
String basicQuery = """
  query {
    viewer {
      login
    }
  }
""";

/// リポジトリ一覧をフェッチする
String repositoriesQuery = """
  query {
    viewer {
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

/// イシュー一覧をフェッチする
/// 個別にユーザ名とリポジトリ名を設定する
String issuesQuery = """
  query {
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
