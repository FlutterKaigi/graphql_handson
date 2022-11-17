# issue 一覧、詳細情報をフェッチする

前章に引き続きフェッチを進めていきますが、下記のように習熟度別でレベルを分けました。

1. Level 1: カードウィジェットを作成する <- 済
2. Level 2: リポジトリ一覧をフェッチする <- 済
3. **Level 3: issue 一覧、issue の詳細情報をフェッチする** <- 当章

当章では Level 3 の issue の一覧、issue の詳細情報をフェッチできることを目指します。

### Level 3: issue 一覧、issue の詳細情報をフェッチする

GitHub API の [`repository`](https://docs.github.com/en/graphql/reference/queries#repository) を利用します。

```dart [lib/graphql/query.dart]
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

::: warning

GraphQL では、この他に Fragment を考慮したクエリなど、より複雑なクエリを書くことも可能となります。その例として、複数の query や mutation の間で共有可能のクエリを指しますが、今回の FlutterKaigi 2022 ハンズオンではその部分を割愛させていただきます。

:::

## 情報をフェッチする

FutureBuilder を利用して `snapshot.data` から ListView を描画します。

issue 一覧並びにその詳細情報をフェッチする場合には、クエリ `issuesQuery` を使用します。

`Repository` クラスと同じく、factory コンストラクタ定義用に `Issue` クラスを準備します。

このとき、下記項目に限定して定義することとします。

- ID (`id`)
- タイトル (`title`)
- 説明文 (`body`)
- URL (`url`)
- 更新日時 (`updatedAt`)

```dart [lib/model/issue.dart]
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

ここで、非同期でフェッチするための関数 `fetchIssues()` を作成します。

```dart [lib/repositories/github_repository.dart]
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

加えて、大事なのは `snapshot.data` で取得する model が `Repository` から `Issue` に変わっていることです。下記の部分を変更しましょう。

```dart [lib/pages/index.dart]
final Issue issue = snapshot.data[index];
```

ここでのポイントは、通信状態による出し分けとなります。

- そもそも通信が安全に終了していますか
- 通信が安全に終了しても、データ `snapshot.data` は存在していますか

```dart [lib/pages/index.dart]
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

## 4 章で目指すべきゴール

途中経過のソースコードを下に示します。

### リポジトリ一覧をフェッチする


```dart [lib/pages/index.dart]
class IssueListPage extends StatelessWidget {
  const IssueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: fetchRepositories(),
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
                final Repository repository = snapshot.data[index];
                return CardItem(
                  title: repository.name,
                  message: repository.description ?? '',
                  url: repository.url,
                  updatedAt: repository.updatedAt,
                );
              },
            );
        }
      },
    );
  }
}
```

### issue 一覧、issue の詳細情報をフェッチする

```dart [lib/pages/index.dart]
class IssueListPage extends StatelessWidget {
  const IssueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
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
                return CardItem(
                  id: issue.id,
                  title: issue.title,
                  message: issue.body ?? '',
                  url: issue.url,
                  updatedAt: issue.updatedAt,
                );
              },
            );
        }
      },
    );
  }
}
```
