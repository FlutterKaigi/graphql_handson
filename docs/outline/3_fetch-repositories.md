# リポジトリ一覧をフェッチする

当章では、アプリ内で GitHub API を実行できるところから、実際に GraphQL のクエリを書くところまで解説していきます。

では、手始めに GitHub API のクエリを書くため、まずは GitHub API の [`viewer`](https://docs.github.com/ja/graphql/reference/queries#viewer) を利用します。

```dart
String basicQuery = """
  query {
    viewer {
      login
    }
  }
""";
```

実際、この `viewer` 配下には、ありとあらゆる項目が設定されています。そのうち `viewer.login` を書くことで私たちが得られる情報は、各自ログインしている GitHub アカウントの ID となります。

ここで GraphQL が REST と違う点で、一部の項目に限定してフェッチすることが可能になります。

その `viewer.login` の情報がフェッチされていることを確認できたら、実際に GitHub 上にある情報の取得を目指しましょう。

下記のように習熟度別でレベルを分けました。

1. **Level 1: リポジトリ一覧をフェッチする** <- 当章
2. Level 2: issue 一覧をフェッチする
3. Level 3: issue の詳細情報をフェッチする

当章では Level 1 のリポジトリ一覧をフェッチできることを目指します。

### Level 1: リポジトリ一覧をフェッチする

引き続き GitHub API の [`viewer`](https://docs.github.com/ja/graphql/reference/queries#viewer) を利用します。

では、下記項目に限定して、フェッチすることを目指しましょう。

- ID (`id`)
- 名前 (`name`)
- URL (`url`)
- 説明文 (`description`)
- 更新日時 (`updatedAt`)

```dart
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
```

## 情報をフェッチする

FutureBuilder を利用して `snapshot.data` から ListView を描画します。

リポジトリ一覧をフェッチする場合には、クエリ `repositoriesQuery` を使用します。

factory コンストラクタを定義するため、まず `Repository` クラスを準備します。

このとき、下記項目に限定して定義することとします。

- ID (`id`)
- 名前 (`name`)
- URL (`url`)
- 説明文 (`description`)
- 更新日時 (`updatedAt`)

```dart
class Repository {
  String id;
  String name;
  String? description;
  String url;
  String updatedAt;

  Repository({
    required this.id,
    required this.name,
    this.description,
    required this.url,
    required this.updatedAt,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      url: json['url'],
      updatedAt: json['updatedAt'],
    );
  }
}
```

REST と違って、必要な項目に限定してフェッチできるのが GraphQL の大きな特徴です。

続いて実際に GraphQL クライアント `client.query()` を利用して、求める情報をフェッチしていきましょう。

ここで、非同期でフェッチするための関数 `fetchRepositories()` を作成します。

```dart
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
```

そして `pages/index.dart` で、いま作成した非同期関数 `fetchRepositories()` を読み込みます。

`FutureBuilder` を利用する場面で、これを使用するポイントは各々の場面による出し分けとなります。

- 実際の通信状態 `snapshot.connectionState` を確認する
- 確認した通信状態を踏まえて、実際のデータ `snapshot.data` の有無を確認する

まずは実際の通信状態 `snapshot.connectionState` を確認します。

```dart
FutureBuilder<dynamic>(
    future: fetchRepositories(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.none:
        case ConnectionState.active:
        case ConnectionState.waiting:
          // 通信状態が waiting (待ち) の場合
          return const Text('Loading');
        case ConnectionState.done:
          // 通信状態が done (完了) の場合
          return Center();
        },
      },
    },
  ),
```

通信が終了したことを踏まえて、実際のデータ `snapshot.data` の有無を確認します。

```dart
FutureBuilder<dynamic>(
    future: fetchRepositories(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      // 通信にエラーが発生した場合
      if (snapshot.hasError) {
        return Center(child: Text('Error : ${snapshot.error}'));
      }

      // 通信に成功も、データが存在しなかった場合
      if (snapshot.data == null) {
        return const Text('No issues');
      }

      // 通信に成功し、無事にデータをフェッチできた場合
      return Center();
    },
  ),
```

ここでのポイントは、通信状態による出し分けとなります。

- そもそも通信が安全に終了していますか
- 通信が安全に終了しても、データ `snapshot.data` は存在していますか

```dart
return Center(
  child: FutureBuilder<dynamic>(
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
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CardItem(
                    title: repository.name,
                    message: repository.description ?? '',
                    url: repository.url,
                    updatedAt: repository.updatedAt,
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

リポジトリ一覧をフェッチする場合も同じく、クエリ `repositoriesQuery` を使用します。

```dart
return Center(
    child: Query(
  options: QueryOptions(
    document: gql(repositoriesQuery),
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

    List? items = (result.data?['viewer']?['repositories']?['nodes']);

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
              title: item['name'],
              message: '',
              url: item['url'] ?? '',
              updatedAt: item['updatedAt'] ?? '',
            ),
          );
        });
  },
));
```
