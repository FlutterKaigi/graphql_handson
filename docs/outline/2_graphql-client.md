# GraphQL クライアントを選定する

当章では、発行したトークンを使用して、アプリ内で GitHub API を実行できるところまで解説していきます。

手順の前に GitHub API の「そもそも」について書いておきます。

## GitHub API とは

GitHub API [v3](https://docs.github.com/ja/rest) が REST で、また [v4](https://docs.github.com/ja/graphql) が GraphQL で製作されています。そもそも REST と比較してしばしば語られる GraphQL の利点として、一度だけの API 呼び出しで必要なデータのみ得られるようになることが挙げられます。

一番容易に GitHub API を試せるのは GitHub CLI で用意されているコマンド `gh api graphql` を使用することです。

HomeBrew をインストールしている場合は `gh` をインストールします。

```bash
brew install gh
```

インストール完了後 `gh auth login` を実行して、手元の環境で `gh` コマンドを使用できるようにします。

```bash
# gh auth login
gh auth login
```

指定のユーザー名 `jiyuujin` における `bio` を取得する際は、下記クエリを実行すると、それが表示されることを確認してください。

```bash
# gh api graphql
gh api graphql -f query='
  query {
    user(login: "jiyuujin") {
      bio
    }
  }
'

{
  "data": {
    "user": {
      "bio": "Web Developer,  HR Adviser and etc | TypeScript | React | NodeJS | Flutter | AWS"
    }
  }
}
```

## Flutter で GraphQL を取り扱う

前置きはさておき、まずは Flutter で GraphQL を取り扱う準備を進めていきましょう。

アプリ内における GraphQL クライアントは、下に示す 3 種類あります。

- [graphql_flutter](https://pub.dev/packages/graphql_flutter)
- [ferry](https://pub.dev/packages/ferry)
- [artemis](https://pub.dev/packages/artemis)

|#|[graphql_flutter](https://pub.dev/packages/graphql_flutter/install)|[ferry](https://pub.dev/packages/ferry/install)|[artemis](https://pub.dev/packages/artemis/install)|
|:---|:---|:---|:---|
|パブリッシャー|zino.company|gql-dart|borges|
|メンテナンス状態|積極的に更新中|メンテナ募集中|積極的に更新中|
|コード生成|[graphql_codegen](https://pub.dev/packages/graphql_codegen/install) 必要|ferry 内蔵|artemis 内蔵|

ざっくり Apollo ライクに使用できる GraphQL クライアントは [graphql_flutter](https://pub.dev/packages/graphql_flutter/install) となります。

この graphql_flutter を利用する際に、合わせてスキーマクラスのコードを生成する必要がない場合は、この中 GraphQL クライアントのインストールでは最も簡単となります。

もしスキーマクラスのコードを生成するなら、別途 [graphql_codegen](https://pub.dev/packages/graphql_codegen/install) をインストールする必要があります。

GraphQL フラグメントの処理に関して柔軟です。その詳細については graphql_codegen の作者の記事をご確認いただければ幸いです。

[@preview](https://budde377.medium.com/structure-your-flutter-graphql-apps-717ab9e46a5d)

### pubspec.yaml で GraphQL の書ける環境を整える

Flutter アプリ内で使う依存関係は、ルートの pubspec.yaml で管理します。

[@preview](https://pub.dev/packages/graphql_flutter)

[@preview](https://pub.dev/packages/graphql)

今回の Flutter × GraphQL ハンズオンでは、graphql_flutter `v5.1.0` と graphql `v5.1.1` を使用します。

```yaml [pubspec.yaml]
dependencies:
  graphql_flutter: ^5.1.0
  graphql: ^5.1.1
```

これを書いた後に `flutter pub get` を実行します。

すると pubspec.lock が更新されます。

## Hive の初期化を行う

GraphQL クライアントに graphql_flutter の使用が決まれば、実際にアプリ内で GraphQL を使用できるよう準備していきましょう。

すると、ここで Hive について考慮する必要があります。

[@preview](https://docs.hivedb.dev/)

GraphQL クライアントのキャッシュに Hive を使用しているため、それらの初期化を行います。

```dart [lib/main.dart]
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const MyApp());
}
```

## GraphQL クライアントを作成する

Hive の初期化が完了すると、いよいよ GraphQL クライアントを作成します。

事前に GraphQLProvider を利用して、Flutter アプリ全体をラップする Provider を作成します。

```dart [lib/provider/app_provider.dart]
import 'package:graphql_flutter/graphql_flutter.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clientValue = ValueNotifier<GraphQLClient>(
      client,
    );

    return GraphQLProvider(
      client: clientValue,
      child: child,
    );
  }
}
```

Provider の `client` で GitHub クライアントを作成します。

```dart [lib/plugins/graphql_client.dart]
import 'package:graphql/client.dart';

/// 環境変数を利用する
const gitHubToken = String.fromEnvironment('GITHUB_TOKEN');

final HttpLink httpLink = HttpLink(
  'https://api.github.com/graphql',
);

final AuthLink authLink = AuthLink(
  getToken: () async => 'Bearer $gitHubToken',
);

final Link link = authLink.concat(httpLink);

final client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: link,
    cache: GraphQLCache(store: HiveStore()),
  ),
);

return GraphQLProvider(
  client: client,
  child: child,
);
```

Apollo クライアントの要領で使用できます。
