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
