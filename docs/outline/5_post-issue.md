# issue を追加、更新する

前章まで、下記習熟度の順にリポジトリと issue の一覧を、issue の詳細情報もフェッチしてきました。

1. Level 1: カードウィジェットを作成する <- 済
2. Level 2: リポジトリ一覧をフェッチする <- 済
3. Level 3: issue 一覧、issue の詳細情報をフェッチする <- 済

当章では issue の情報を追加、更新できることを目指します。

## 入力専用のフォームを作成する

issue を追加、並びに更新するため、入力専用のフォームを作成する必要があります。

まず、フォームでは [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) を利用します。

::: tip

Flutter では StatelessWidget と StatefulWidget の 2 種類のウェジェットがあります。前者 (StatelessWidget) で扱う値は全てイミュータブル (不変) となり、プロパティを変更することはできません。

また、後者 (StatefulWidget) そのもののクラスは不変となる一方、値はそのクラスにおいて保持すること (ミュータブル) となります。

:::

では StatefulWidget を作成していきましょう。

```dart [lib/pages/issue_info.dart]
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
`SingleChildScrollView` で `Column` を Wrap することでスクロールする可能になります。 (スクロール不可の状態で縦の画面サイズが足らないとエラーが発生して画面描画が出来ません) 

```dart [lib/pages/issue_info.dart]
    Scaffold(
      body: Container(
        color: const Color(0xFFEFEFEF),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //
            ],
          ),
        ),
      ),
    );
```

### TextField (TextFormField) フォームを設計する

続いて [`TextField`](https://api.flutter.dev/flutter/material/TextField-class.html) フォームを設計します。

なお、似た API として [`TextFormField`](https://api.flutter.dev/flutter/material/TextFormField-class.html) は `TextField` を拡張しているため、同じように使用することができます。

#### title を入力するフォーム

title の入力と同時に `TextField` の `onChanged` アクションを発火します。

```dart [lib/pages/issue_info.dart]
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

```dart [lib/pages/issue_info.dart]
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

```dart [lib/pages/issue_info.dart]
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

```dart [lib/pages/issue_info.dart]
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

API の実行に必要なものは下に示す通りとなります。

- タイトル (`title`)
- 詳細 (`body`)

```dart [lib/pages/issue_info.dart]
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

```dart [lib/pages/issue_info.dart]
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

今回は GitHub API [Explorer](https://docs.github.com/ja/graphql/overview/explorer) を利用して、リポジトリの ID を取得します。

GitHub 認証を済ませることで、気軽に GraphQL クエリを実行できます。

```graphql
{
  viewer {
    login
  }
  repository(name: "ohayo-developers", owner: "jiyuujin") {
    id
  }
}
```

GraphQL クエリを直接、書いても問題ありません。

下に示すように、左の Explorer タブより「ぽちぽち」とチェックを付けることもできます。

![](https://i.imgur.com/z9U59Xz.png)

![](https://i.imgur.com/OyY8jsH.png)

では GitHub API の [`createIssue`](https://docs.github.com/en/graphql/reference/mutations#createissue) を利用します。

```dart [lib/graphql/mutation.dart]
const String createMutation = '''
  mutation () {
    createIssue(input: {
      repositoryId: "ご自分のリポジトリIDに置き換えてください",
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

```dart [lib/graphql/mutation.dart]
const String createMutation = '''
  mutation (\$titleText: String!, \$bodyText: String!) {
    createIssue(input: {
      repositoryId: "ご自分のリポジトリIDに置き換えてください",
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

```dart [lib/repositories/github_repository.dart]
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

```dart [lib/main.dart]
return Scaffold(
  appBar: AppBar(
    title: Text(_appTitle),
    actions: [
      // IconButton を設定する
    ],
  ),
  body: const IssueInputPage(),
);
```

issue を追加する際は、既に title や body が設定されているという訳ではありません。

したがって `IssueInputPage()` をそのまま読み込むこととします。

```dart [lib/pages/index.dart]
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

ここまで作成することが出来たらアプリケーションを起動して、動くか確認してみましょう。  
上手くテキストを入力する事が出来れば、 Issue を追加することが出来るはずです。

::: tip

[`IconClass`](https://api.flutter.dev/flutter/material/Icons-class.html)には Flutter 側で Material Icons に即したアイコンを用意されています。 (今回は `Icons.add_circle_outline` を利用しました。)   
[`GoogleFonts`](https://fonts.google.com/icons?selected=Material+Icons)でも使いたいアイコンを探すことが出来るのでぜひ利用してみてください。

:::

## issue を更新する

GitHub API の [`updateIssue`](https://docs.github.com/en/graphql/reference/mutations#updateissue) を利用します。

```dart [lib/graphql/mutation.dart]
const String updateMutation = '''
  mutation () {
    updateIssue(input: {
      id: "IssueのIDに置き換えます",
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

```dart [lib/graphql/mutation.dart]
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

```dart [lib/repositories/github_repository.dart]
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

ここからは Issue 更新用の導線をレイアウトに追加していきます。  
`CardItemClass` で Issue の内容を表示していた `ColumnWidget` を `RowWidget` で Wrap してください。  
Issue アイテムの右端に更新用のボタンを追加します。

```dart [lib/pages/index.dart]
Card(
  color: Colors.white,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Issueの中身
      Flexible(
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
      // IconButtonを設定する
    ],
  ),
),
```

次に更新用 `IconButton` を追加します。ボタンをタップした際には `IssueInputPage` に遷移させます。

issue を更新する際は、既に設定されている title や body に加え id も設定する必要があります。

したがって `IssueInputPage()` にそれらのパラメータを読み込むこととします。

```dart [lib/pages/index.dart]
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

このままでは `IssueInputPage` が引数に id らのパラメータを受け取ることが出来ないため対応させる必要があります。  

修正項目を列挙したので、完成形ソースコードを参照しながら Issue の更新が出来るように修正してみましょう。

- 引数として `named_parameter` に `id` , `title` , `body` を受け取るようにする
- 受け取ったパラメータをデフォルト値としてセットする
- デフォルト値は遅延初期化を行う
-  `initState()` メソッドを追加してデフォルト値の有無を確認する
  - 何も渡されていなければ Issue の追加として画面が呼び出されたので空を代入しておく
- デフォルト値がある場合は Issue タイトル、 Issue ボディに初期値として表示された状態にする

## 5 章で目指すべきゴール

完成形のソースコードを下に示します。

### カードウィジェットを作成する

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
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
            )
          ],
        ),
      ),
    );
  }
}
```

### issue を追加、更新する

```dart [lib/pages/issue_info.dart]
class IssueInputPage extends StatefulWidget {
  const IssueInputPage({super.key, this.id, this.title, this.body});

  final String? id;
  final String? title;
  final String? body;

  @override
  State<IssueInputPage> createState() => _IssueInputState();
}

class _IssueInputState extends State<IssueInputPage> {
  late String titleInputText;
  late String bodyInputText;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    titleInputText = widget.title ?? "";
    bodyInputText = widget.body ?? "";
  }

  void _changeEnabled() {
    if (titleInputText.isNotEmpty && bodyInputText.isNotEmpty) {
      _isEnabled = true;
    } else {
      _isEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.id == null
            ? const Text('Issue Create')
            : const Text('Issue Update'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFEFEFEF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
                      initialValue: widget.title ?? titleInputText,
                      onChanged: (titleValue) {
                        titleInputText = titleValue;
                        setState(() {
                          _changeEnabled();
                        });
                      },
                    ),
                  ),
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
                      )),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(left: 21),
                    child: TextFormField(
                      keyboardType: TextInputType.multiline, // 改行の可否
                      maxLines: 4, // 改行可能な行数
                      decoration: const InputDecoration(
                        hintText: '入力してください',
                        border: InputBorder.none,
                      ),
                      initialValue: widget.body ?? bodyInputText,
                      onChanged: (bodyValue) {
                        bodyInputText = bodyValue;
                        setState(() {
                          _changeEnabled();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 21),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: !_isEnabled
                    ? null
                    : () {
                        if (widget.id == null) {
                          createIssue(
                            title: titleInputText,
                            body: bodyInputText,
                          );
                        } else {
                          updateIssue(
                            id: widget.id ?? '',
                            title: titleInputText,
                            body: bodyInputText,
                          );
                        }
                        Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  widget.id == null ? '保存' : '更新',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
