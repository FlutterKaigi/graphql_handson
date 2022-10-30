import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_handson/pages/index.dart';
import 'package:graphql_handson/pages/issue_create.dart';
import 'package:graphql_handson/provider/app_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'FlutterKaigi 2022';
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return AppProvider(
      child: Builder(builder: (context) {
        return MaterialApp(
          title: title,
          home: Home(
            appTitle: title,
            scaffoldKey: scaffoldKey,
          ),
        );
      }),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    final Key? key,
    required String appTitle,
    required GlobalKey<ScaffoldState> scaffoldKey,
  })  : _appTitle = appTitle,
        _scaffoldKey = scaffoldKey,
        super(key: key);

  final String _appTitle;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_appTitle),
        actions: [
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
            ),
          )
        ],
      ),
      body: const MyTopPage(),
    );
  }
}
