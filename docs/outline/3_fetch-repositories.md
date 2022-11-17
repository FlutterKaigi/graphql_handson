# リポジトリ一覧をフェッチする

当章では、アプリ内で GitHub API を実行できるところから、実際に GraphQL のクエリを書くところまで解説していきます。

では、手始めに GitHub API のクエリを書くため、まずは GitHub API の [`viewer`](https://docs.github.com/ja/graphql/reference/queries#viewer) を利用します。

```dart [lib/graphql/query.dart]
String basicQuery = """
  query {
    viewer {
      login
    }
  }
""";
```

GraphQL クエリの実行結果を確認するには、GitHub API [Explorer](https://docs.github.com/ja/graphql/overview/explorer) を利用するのが容易となります。

GitHub 認証を済ませることで、気軽に GraphQL クエリを実行できます。

```graphql
{
  viewer {
    login
  }
}
```

GraphQL クエリを直接書いても、Explorer タブより「ぽちぽち」とチェックを付けても、構いません。

実際、この `viewer` 配下には、ありとあらゆる項目が設定されています。そのうち `viewer.login` を書くことで私たちが得られる情報は、各自ログインしている GitHub アカウントの ID となります。

ここで GraphQL が REST と違う点で、一部の項目に限定してフェッチすることが可能になります。

下記のように習熟度別でレベルを分けました。

1. **Level 1: カードウィジェットを作成する** <- 当章
2. **Level 2: リポジトリ一覧をフェッチする** <- 当章
3. Level 3: issue 一覧、詳細情報をフェッチする

当章では Level 1 のリポジトリ一覧をフェッチできることを目指します。

### リストを表示する大本のWidgetを作成する

今回のハンズオンでは、自身の GitHub アカウントに属しているリポジトリ、issue の一覧、issue の詳細情報を表示します。  

まず初めにリスト表示するための画面を作りましょう。

```dart [lib/pages/index.dart]
class IssueListPage extends StatelessWidget {
  const IssueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
```

### カードウィジェットを作成する

最終的に一覧表示させたいため、事前にカードウィジェットを作成する必要があります。

- ID (`id`) <- issue を更新する時に限って使用する
- タイトル (`title`)
- 詳細 (`message`)
- URL (`url`)
- 更新日時 (`updatedAt`)

```dart [lib/pages/index.dart]
class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    this.id,
    required this.title,
    required this.message,
    required this.url,
    required this.updatedAt,
  });
  final String? id;
  final String title;
  final String message;
  final String url;
  final String updatedAt;
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
```

まずは、カード内のレイアウトを設計します。

`Column` を使うことで `children` 配下に置かれたウィジェットを縦に並べられます。

```dart
Container(
  color: const Color(0xFFEFEFEF),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      //
    ],
  ),
),
```


次に、カード全体のレイアウトを整えます。  
[`Directionality`](https://api.flutter.dev/flutter/intl/TextDirection-class.html) ウィジェットはテキストの表示方向を指定できます。  
[`Card`](https://api.flutter.dev/flutter/material/Card-class.html) ウィジェットはマテリアルデザインとして定義されるカードコンポーネントとしての見た目を整えることが出来ます.  

`Colors.white` は `const Color(0xFFEFEFEF)` と同一のものになります。

```dart
    Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //
          ],
        ),
      ),
    )
```

カード内で、複数の情報を設定します。

- タイトル (`title`)
- 詳細 (`message`)
- 更新日時 (`updatedAt`)

続いて [`Text`](https://docs.flutter.dev/development/ui/widgets/text) ウィジェットを設計します。

[@preview](https://docs.flutter.dev/development/ui/widgets/text)

タイトル `title` を表示するため Text ウィジェットを利用します。


```dart [lib/pages/index.dart]
Container(
  padding: const EdgeInsets.only(top: 4),
  child: Text(
    title,
    style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87),
      ),
),
```

詳細 `message` を表示するため Text ウィジェットを利用します。

```dart [lib/pages/index.dart]
Text(
  message,
  style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black87),
),
```

更新日時 `updatedAt` を表示するため Text ウィジェットを利用します。

```dart [lib/pages/index.dart]
Text(
  updatedAt,
  style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black87),
),
```

それぞれのウィジェットを `Column` の `children` 配下に設定します。

```dart [lib/pages/index.dart]
class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    this.id,
    required this.title,
    required this.message,
    required this.url,
    required this.updatedAt,
  });
  final String? id;
  final String title;
  final String message;
  final String url;
  final String updatedAt;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87),
            ),
            Text(
              updatedAt,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Level 2: リポジトリ一覧をフェッチする

引き続き GitHub API の [`viewer`](https://docs.github.com/ja/graphql/reference/queries#viewer) を利用します。

では、下記項目に限定して、フェッチすることを目指しましょう。

- ID (`id`)
- 名前 (`name`)
- URL (`url`)
- 説明文 (`description`)
- 更新日時 (`updatedAt`)

```dart [lib/graphql/query.dart]
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

```dart [lib/model/repository.dart]
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

```dart [lib/repositories/github_repository.dart]
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

事前に作成した`IssueListPage`に組み込んでいきます。

```dart [lib/pages/index.dart]
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
    }
  },
);
```

通信が終了したことを踏まえて、実際のデータ `snapshot.data` の有無を確認します。

```dart [lib/pages/index.dart]
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
);
```

ここでのポイントは、通信状態による出し分けとなります。

- そもそも通信が安全に終了していますか
- 通信が安全に終了しても、データ `snapshot.data` は存在していますか

```dart [lib/pages/index.dart]
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
            return const Text('No repositories');
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
      }
    ),
  );
```

結果として、こんな形でウィジェットに含めていくこととなります。

最後に`main.dart`の`MyHomePage Class`に`IssueListPage`を組み込んでアプリケーションを起動してみましょう。  
上手く動作すればGithubリポジトリの一覧を確認する事が出来るはずです。

## 補足

pub.dev 公式の [graphql_flutter](https://pub.dev/packages/graphql_flutter) に則って [GraphQL Provider](https://pub.dev/packages/graphql_flutter#graphql-provider) を利用します。

[@preview](https://pub.dev/packages/graphql_flutter)

