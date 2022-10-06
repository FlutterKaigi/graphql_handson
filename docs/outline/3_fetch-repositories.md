# リポジトリ一覧をフェッチする

当章では、アプリ内で GitHub API を実行できるところから、実際に GraphQL のクエリを書くところまで解説していきます。

では、手始めに GitHub API のクエリを書いていきましょう。

```dart
String basicQuery = """
  query {
    viewer {
      login
    }
  }
""";
```

`viewer.login` を書くことで私たちが得られる情報は、各自ログインしている GitHub アカウントの ID となります。

それを確認できたら、実際に GitHub 上にある情報の取得を目指しましょう。

下記のように習熟度別でレベルを分けました。

1. **Level 1: リポジトリ一覧を取得する** <- 当章
2. Level 2: イシュー一覧を取得する
3. Level 3: イシューの詳細情報を取得する

当章では Level 1 のリポジトリ一覧を取得できることを目指します。

### Level 1: リポジトリ一覧を取得する

```dart
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
```

## 情報をフェッチする

FutureBuilder を利用して `snapshot.data` から ListView を描画します。

リポジトリ一覧を取得する場合は、クエリ `repositoriesQuery` を使用します。



TBD



## 補足

pub.dev 公式の [graphql_flutter](https://pub.dev/packages/graphql_flutter) に則って [GraphQL Provider](https://pub.dev/packages/graphql_flutter#graphql-provider) を利用します。

[@preview](https://pub.dev/packages/graphql_flutter)

リポジトリ一覧を取得する場合も同じく、クエリ `repositoriesQuery` を使用します。

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
