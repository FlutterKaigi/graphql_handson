# Flutter で環境変数を取り扱う

当章では、環境変数 `GITHUB_TOKEN` の設定を準備するところから、アプリ内でその使用を開始するところまで解説していきます。

下記手順の通り、進めていきましょう。

- GitHub の管理画面でトークンを発行する
- Flutter で発行済みの環境変数を使用する

## GitHub の管理画面でトークンを発行する

今回は GitHub API (中でも GitHub API v4 についてはこの後記載) を使います。

まず GitHub のアカウントを持っていないという方は、そのアカウントを取得してください。

GitHub API を手元のアプリで使うために、アカウントを取得する必要があります。

![](https://i.imgur.com/kP9kvSR.png)

各自 GitHub アカウント取得した後は、早速 GitHub API を使うための準備を進めましょう。

と、ここでトークンの作成に 2 つの選択肢が存在しています。

- 各自アカウントのトークンを作成する
- GitHub Apps のトークンを作成する

両者の違いについては [記事](https://techblog.kayac.com/github-apps-bot) を確認いただければ、大変分かりやすいと考えています。

今回は前者を利用させていただきますが、各自 GitHub の Developer Settings でトークンを作成します。

こちらの Developer Settings より `Personal access tokens` から `Token(classic)` を選択します。
※ `Fine-grained tokens` という新しい作成方法もありますが今回は割愛します。 ([参考](https://github.blog/2022-10-18-introducing-fine-grained-personal-access-tokens-for-github/))

![](https://i.imgur.com/qPu8TDv.png)

目的は GitHub のリポジトリ一覧や、特定のリポジトリにおける issue 一覧の取得となります。

この目的を実現するため 2 つの scope にチェックを入れる必要があります。

- repo の `public_repo` を指定する
- `admin:repo_hook` を指定する

`Generate token` をクリックしましょう。

すると、トークンが発行されることを確認し、それを手元のメモに記録しておきましょう。

## Flutter で発行済みの環境変数を使用する

Flutter で環境変数を取り扱うには、下記 2 種類の方法から選択する必要があります。

- `dart-define` オプションを利用する
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) を利用する

`dart-define` は Flutter アプリのビルドや実行の際に環境変数を設定するためのパラメータで `flutter build web --dart-define HOGE_TOKEN=hogehoge` のように使えます。(`web` の部分には build したいプラットフォームを入力します。今回は web を選択します。)

今回は、この前者 `dart-define` オプションを利用して、発行済みの環境変数を使用することとします。

先に GitHub 管理画面で発行した際に生成されたトークンを `--dart-define` オプションと合わせ設定しましょう。

```bash
flutter build --dart-define GITHUB_TOKEN=hogehoge
```

基本的にこれだけの対応を済ませることで GitHub API を使うための準備は整いました。

## 補足

なお、今回は使用しなかった [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) についても解説しておきます。

.env を Git 管理下から除外することを前提に、ルートの main.dart で .env を読み込みます。

```dart [lib/main.dart]
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

Future main() async {
  await dotenv.load(); // .env を読み込む
  runApp(MyApp());
}
```
