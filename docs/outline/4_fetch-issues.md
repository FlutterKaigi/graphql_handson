# イシュー一覧、詳細情報をフェッチする

当章では、アプリ内で GitHub API を実行できるところから、実際に GraphQL のクエリを書くところまで解説していきます。

前章に引き続き、下記のように習熟度別でレベルを分けています。

1. Level 1: リポジトリ一覧を取得する
2. **Level 2: イシュー一覧を取得する** <- 当章
3. **Level 3: イシューの詳細情報を取得する** <- 当章

当章では Level 2 のイシュー一覧、さらに Level 3 のイシューの詳細情報を取得できることを目指します。

### Level 2: イシュー一覧を取得する

GitHub API の [`repository`](https://docs.github.com/ja/graphql/reference/mutations#createissue) を利用します。

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

引き続き GitHub API の [`repository`](https://docs.github.com/ja/graphql/reference/mutations#createissue) を利用します。

では、下記項目に限定して、フェッチすることを目指しましょう。

- ID (`id`)
- タイトル (`title`)
- 説明文 (`body`)
- URL (`url`)
- 更新日時 (`updatedAt`)

```dart
String issuesQuery = """
  query {
    repository(name: "_graphql_handson", owner: "FlutterKaigi") {
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

さらに、イシューの詳細情報をフェッチしたい場合は、下記のように掘り下げられます。

- ラベル (`labels.nodes.{id,name}`)
- タイムライン (`timelineItems.nodes.{id,body}`)
- アサイン (`participants.nodes.{id,login,name,avatarUrl}`)

```dart
String issuesQuery = """
  query {
    repository(name: "_graphql_handson", owner: "FlutterKaigi") {
      issues(
        states: OPEN
        first: 100
        orderBy: { field: CREATED_AT, direction: DESC }
      ) {
        nodes {
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

イシュー一覧並びにその詳細情報を取得する場合には、クエリ `issuesQuery` を使用します。

`Repository` クラスと同じく、factory コンストラクタ定義用に `Issue` クラスを準備します。

このとき、下記項目に限定して定義することとします。

- ID (`id`)
- タイトル (`title`)
- 説明文 (`body`)
- URL (`url`)
- 更新日時 (`updatedAt`)

```dart
class Issue {
  String id;
  String title;
  String? body;
  String url;
  String updatedAt;

  Issue({
    required this.id,
    required this.title,
    this.body,
    required this.url,
    required this.updatedAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      url: json['url'],
      updatedAt: json['updatedAt'],
    );
  }
}
```

なお、こちらも同じく、必要な項目に限定してフェッチできる GraphQL の大きな特徴を活かしています。

続いて実際に GraphQL クライアント `client.query()` を利用して、求める情報をフェッチしていきましょう。

ここで、非同期で取得するための関数 `fetchIssues()` を作成します。

```dart
import 'package:graphql_handson/graphql/query.dart';
import 'package:graphql_handson/model/issue.dart';
import 'package:graphql_handson/plugins/graphql_client.dart';

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
```

そして `pages/index.dart` で、いま作成した非同期関数 `fetchIssues()` を読み込みます。

前章の記述を再掲させていただきますが `FutureBuilder` を利用する場面で、これを使用するポイントは各々の場面による出し分けとなります。

- 実際の通信状態 `snapshot.connectionState` を確認する
- 確認した通信状態を踏まえて、実際のデータ `snapshot.data` の有無を確認する

ここでのポイントは、通信状態による出し分けとなります。

- そもそも通信が安全に終了していますか
- 通信が安全に終了しても、データ `snapshot.data` は存在していますか

```dart
return Center(
  child: FutureBuilder<dynamic>(
    future: fetchIssues(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.none:
        case ConnectionState.active:
        case ConnectionState.waiting:
          return const Text('Loading');
        case ConnectionState.done:
          if (snapshot.hasError) {
            return Center(child: Text('Error : ${snapshot.error}'));
          }

          if (snapshot.data == null) {
            return const Text('No issues');
          }

          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                final Issue issue = snapshot.data[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CardItem(
                    title: issue.title,
                    message: issue.body ?? '',
                    url: issue.url,
                    updatedAt: issue.updatedAt,
                  ),
                );
              },
            );
        },
      },
    ),
  );
```

結果として、こんな形でウィジェットに含めていくこととなります。

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
