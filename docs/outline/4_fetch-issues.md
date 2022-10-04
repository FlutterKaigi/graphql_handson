# イシュー一覧、詳細情報をフェッチする

当章では、アプリ内で GitHub API を実行できるところから、実際に GraphQL のクエリを書くところまで解説していきます。

前章に引き続き、下記のように習熟度別でレベルを分けています。

1. Level 1: リポジトリ一覧を取得する
2. **Level 2: イシュー一覧を取得する** <- 当章
3. **Level 3: イシューの詳細情報を取得する** <- 当章

当章では Level 2 のイシュー一覧、さらに Level 3 のイシューの詳細情報を取得できることを目指します。

### Level 2: イシュー一覧を取得する

```dart
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
```

### Level 3: イシューの詳細情報を取得する

イシューの詳細情報について、さらに掘り下げます。

- ラベル
- タイムライン
- アサイン

```dart
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
          number
          labels(last: 10) {
            nodes {
              id
              name
            }
          }
          timelineItems(first: 20) {
            nodes {
              ... on IssueComment {
                id
                body
              }
            }
          }
          participants(last: 10) {
            nodes {
              id
              login
              name
              avatarUrl(size: 40)
            }
          }
        }
      }
    }
  }
""";
```

## 情報をフェッチする

FutureBuilder を利用して `snapshot.data` から ListView を描画します。

イシュー一覧並びにその詳細情報を取得する場合は、クエリ `issuesQuery` を使用します。



TBD



## 補足

pub.dev 公式の [graphql_flutter](https://pub.dev/packages/graphql_flutter) に則って [GraphQL Provider](https://pub.dev/packages/graphql_flutter#graphql-provider) を利用します。

[@preview](https://pub.dev/packages/graphql_flutter)

続いて、イシュー一覧並びにその詳細情報を取得する場合も同じく、クエリ `issuesQuery` を使用します。

```dart
return Center(
    child: Query(
  options: QueryOptions(
    document: gql(issuesQuery),
    variables: const {
      //
    },
    fetchPolicy: FetchPolicy.noCache,
    cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    pollInterval: const Duration(seconds: 10),
  ),
  builder: (QueryResult result,
      {VoidCallback? refetch, FetchMore? fetchMore}) {
    if (result.hasException) {
      return Text(result.exception.toString());
     }

    if (result.isLoading) {
      return const Text('Loading');
    }

    List? items = (result.data?['repository']?['issues']?['nodes']);

    if (items == null) {
      return const Text('No issues');
    }

    return ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CardItem(
              title: item['title'] ?? '',
              message: item['description'] ?? '',
              url: item['url'] ?? '',
              updatedAt: item['updatedAt'] ?? '',
            ),
          );
        });
  },
));
```
