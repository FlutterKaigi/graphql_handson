# issue を追加、更新する

前章まで、下記習熟度の順にリポジトリと issue の一覧を、また issue の詳細情報もフェッチしてきました。

1. Level 1: リポジトリ一覧をフェッチする <- 済
2. Level 2: issue 一覧をフェッチする <- 済
3. Level 3: issue の詳細情報をフェッチする <- 済

当章では issue の情報を追加、更新できることを目指します。

## 入力専用のフォームを作成する

issue を追加、並びに更新するため、入力専用のフォームを作成する必要があります。

まず、フォームでは [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) を利用します。

[@preview](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)

::: tip

Flutter では StatelessWidget と StatefulWidget の 2 種類のウェジェットがあります。前者 (StatelessWidget) で扱う値は全て、イミュータブル (不変) となり、プロパティを変更することはできません。

また、後者 (StatefulWidget) そのもののクラスは不変となる一方、値はそのクラスにおいて保持すること (ミュータブル) となります。

:::

では StatefulWidget を作成していきましょう。

```dart
class IssueInputPage extends StatefulWidget {
  const IssueInputPage({super.key});

  @override
  State<IssueInputPage> createState() => _IssueInputState();
}

class _IssueInputState extends State<IssueInputPage> {
  String titleInputText = '';
  String bodyInputText = '';
  bool _isEnabled = false;

  @override
  Widget build(BuildContext context) {
    //
  }
}
```

今回 StatefulWidget で保持する値は、下に示す通りとなります。

- issue の追加、更新を実行する際に渡されるもの
   - タイトル (`titleInputText`)
   - 詳細 (`bodyInputText`)
- issue の追加、更新を実行できるか否かを判定するため必要なもの
   - ボタンの表示を制御するフラグ (`_isEnabled`)

### フォーム全体のレイアウトを設計する

まずは、フォーム全体のレイアウトを設計します。

`Column` を使うことで `children` 配下に置かれたウィジェットを縦に並べられます。

```dart
Container(
  color: const Color(0xFFEFEFEF),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      //
    ],
  ),
),
```

### TextField (TextFormField) フォームを設計する

続いて [`TextField`](https://api.flutter.dev/flutter/material/TextField-class.html) フォームを設計します。

[@preview](https://api.flutter.dev/flutter/material/TextField-class.html)

なお、似た API として [`TextFormField`](https://api.flutter.dev/flutter/material/TextFormField-class.html) は `TextField` を拡張しているため、同じように使用することができます。

[@preview](https://api.flutter.dev/flutter/material/TextFormField-class.html)

#### title を入力するフォーム

title の入力と同時に `TextField` の `onChanged` アクションを発火します。

```dart
Container(
  color: Colors.white,
  padding: const EdgeInsets.only(
    left: 21,
    top: 10,
    bottom: 10,
  ),
  child: const Text(
    'title',
    style: TextStyle(
      fontSize: 16,
    ),
  ),
),
Container(
  padding: const EdgeInsets.only(left: 21),
  child: TextFormField(
    decoration: const InputDecoration(
      hintText: '入力してください',
      border: InputBorder.none,
    ),
    initialValue: titleInputText, // TextFormField を使用する際は、ここで初期値を設定できる
    onChanged: (titleValue) {
      titleInputText = titleValue;
      setState(() {
        _changeEnabled(); // ボタンの表示を制御する
      });
    },
  ),
),
```

`TextFormField` を使用する際は `initialValue` のプロパティで title の初期値を設定できます。

issue の追加、更新を実行するのに、必要な `titleInputText` に入力したものを設定します。

これを確認するため `_changeEnabled()` で submit ボタンの表示を制御します。

```dart
class _IssueInputState extends State<IssueInputPage> {
  void _changeEnabled() {
    if (titleInputText.isNotEmpty && bodyInputText.isNotEmpty) {
      _isEnabled = true;
    } else {
      _isEnabled = false;
    }
  }
}
```

#### body を入力するフォーム

複数行に対する `TextField` フォームも、先の `TextField` フォームと同じように設計します。

body の入力と同時に `TextField` の `onChanged` アクションを発火します。

```dart
Container(
  color: Colors.white,
  padding: const EdgeInsets.only(
    left: 21,
    top: 10,
    bottom: 10,
  ),
  child: const Text(
    'body',
    style: TextStyle(
      fontSize: 16,
    ),
  ),
),
Container(
  padding: const EdgeInsets.only(left: 21),
  child: TextFormField(
    keyboardType: TextInputType.multiline, // 改行の可否
    maxLines: 4, // 改行可能な行数
    decoration: const InputDecoration(
      hintText: '入力してください',
      border: InputBorder.none,
    ),
    initialValue: bodyInputText, // TextFormField を使用する際は、ここで初期値を設定できる
    onChanged: (bodyValue) {
      bodyInputText = bodyValue;
      setState(() {
        _changeEnabled(); // ボタンの表示を制御する
      });
    },
  ),
),
```

`TextFormField` を使用する際は `initialValue` のプロパティで body の初期値を設定できます。

issue を更新する場合も同じく、これを確認するため `_changeEnabled()` でボタンの表示を制御します。

```dart
class _IssueInputState extends State<IssueInputPage> {
  void _changeEnabled() {
    if (titleInputText.isNotEmpty && bodyInputText.isNotEmpty) {
      _isEnabled = true;
    } else {
      _isEnabled = false;
    }
  }
}
```

#### submit を実行するボタン

変数 `_isEnabled` を定義することで、ボタンの表示制御に活用します。

```dart
bool _isEnabled = false;
```

issue を追加するため [`ElevatedButton`](https://api.flutter.dev/flutter/material/ElevatedButton-class.html) ボタンを使用します。

[@preview](https://api.flutter.dev/flutter/material/ElevatedButton-class.html)

API の実行に必要なものは下に示す通りとなります。

- タイトル (`title`)
- 詳細 (`body`)

```dart
ElevatedButton(
  onPressed: !_isEnabled
    ? null
    : () {
      createIssue(
        title: titleInputText,
        body: bodyInputText,
      );
      Navigator.of(context).pop();
    },
  style: ElevatedButton.styleFrom(
    fixedSize: const Size(80, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
  ),
  child: const Text('保存'),
),
```

定義済み `_isEnabled` の有無を判定して、実際にボタンの発火する内容を変更することができます。

issue を更新する際は ID も合わせて入力する必要があります。

```dart
ElevatedButton(
  onPressed: !_isEnabled
    ? null
    : () {
      updateIssue(
        id: widget.id ?? '', // 別途 Issue の ID を入力して API を実行する必要がある
        title: titleInputText,
        body: bodyInputText,
      );
      Navigator.of(context).pop();
    },
  style: ElevatedButton.styleFrom(
    fixedSize: const Size(80, 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
  ),
  child: const Text('更新'),
),
```

これをもって API を実行することができます。

## issue を追加する

GitHub API の [`createIssue`](https://docs.github.com/en/graphql/reference/mutations#createissue) を利用します。

```dart
const String createMutation = '''
  mutation () {
    createIssue(input: {
      repositoryId: "R_kgDOGLUl6Q",
      title: "Test",
      body: "あああ"
    }) {
      issue {
        id
      }
    }
  }
''';
```

では、下記項目に限定して、ポストすることを目指しましょう。

GraphQL では、フェッチ同様ポストする場面でも、入力する値を限定できます。

- Issue のタイトル (`title`)
- Issue の説明文 (`body`)

```dart
const String createMutation = '''
  mutation (\$titleText: String!, \$bodyText: String!) {
    createIssue(input: {
      repositoryId: "R_kgDOGLUl6Q",
      title: \$titleText,
      body: \$bodyText
    }) {
      issue {
        id
      }
    }
  }
''';
```

実際に GraphQL クライアント `client.mutate()` を利用して、求める情報をポストしていきましょう。

ここで、非同期でポストするための関数 `createIssue()` を作成します。

```dart
import 'package:graphql_handson/graphql/mutation.dart';
import 'package:graphql_handson/model/issue.dart';
import 'package:graphql_handson/plugins/graphql_client.dart';

Future<void> createIssue({required String title, required String body}) async {
  final MutationOptions options = MutationOptions(
    document: gql(createMutation),
    variables: <String, dynamic>{
      'titleText': title,
      'bodyText': body,
    },
  );

  final QueryResult result = await client.mutate(options);
  if (result.hasException) {
    log(result.exception.toString());
    return;
  }
}
```

そして `main.dart` で、いま作成した非同期関数 `createIssue()` を読み込みます。

AppBar の `actions` に IconButton を設定します。

```dart
return Scaffold(
  key: _scaffoldKey,
  appBar: AppBar(
    title: Text(_appTitle),
    actions: [
      // IconButton を設定する
    ],
  ),
  body: const MyTopPage(),
);
```

issue を追加する際は、既に title や body が設定されているという訳ではありません。

したがって `IssueInputPage()` をそのまま読み込むこととします。

```dart
IconButton(
  onPressed: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return const IssueInputPage();
      },
    ),
  ),
  icon: const Icon(
    Icons.add_circle_outline,
    color: Colors.black,
  ),
),
```

## issue を更新する

GitHub API の [`updateIssue`](https://docs.github.com/en/graphql/reference/mutations#updateissue) を利用します。

```dart
const String updateMutation = '''
  mutation () {
    updateIssue(input: {
      id: "I_kwDOGLUl6c5VjjjY",
      title: "Test 2",
      body: "いいい"
    }) {
      issue {
        id
      }
    }
  }
''';
```

では、下記項目に限定して、ポストすることを目指しましょう。

GraphQL では、フェッチ同様ポストする場面でも、入力する値を限定できます。

- Issue の ID (`id`)
- Issue のタイトル (`title`)
- Issue の説明文 (`body`)

```dart
const String updateMutation = '''
  mutation (\$idText: ID!, \$titleText: String!, \$bodyText: String!) {
    updateIssue(input: {
      id: \$idText,
      title: \$titleText,
      body: \$bodyText
    }) {
      issue {
        id
      }
    }
  }
''';
```

issue 追加と同じく GraphQL クライアント `client.mutate()` を利用して、求める情報をポストしていきましょう。

ここで、非同期でポストするための関数 `updateIssue()` を作成します。

```dart
import 'package:graphql_handson/graphql/mutation.dart';
import 'package:graphql_handson/model/issue.dart';
import 'package:graphql_handson/plugins/graphql_client.dart';

Future<void> updateIssue(
    {required String id, required String title, required String body}) async {
  final MutationOptions options = MutationOptions(
    document: gql(updateMutation),
    variables: <String, dynamic>{
      'idText': id,
      'titleText': title,
      'bodyText': body,
    },
  );

  final QueryResult result = await client.mutate(options);
  if (result.hasException) {
    log(result.exception.toString());
    return;
  }
}
```

そして `pages/index.dart` で、いま作成した非同期関数 `updateIssue()` を読み込みます。

```dart
Card(
  color: Colors.white,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // IconButton を設定する
    ],
  ),
),
```

issue を更新する際は、既に設定されている title や body に加え id も設定する必要があります。

したがって `IssueInputPage()` にそれらのパラメータを読み込むこととします。

```dart
IconButton(
  onPressed: () => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return IssueInputPage(
          id: id,
          title: title,
          body: message,
        );
      },
    ),
  ),
  icon: const Icon(
    Icons.create_outlined,
  ),
),
```
