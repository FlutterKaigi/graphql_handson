import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_handson/pages/index.dart';
import 'package:graphql_handson/provider/app_provider.dart';
import 'package:graphql_handson/repositories/github_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    const title = 'FlutterKaigi 2022';
    return AppProvider(
      child: Builder(builder: (context) {
        return MaterialApp(
          title: title,
          home: Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: const Text(title),
              actions: [
                IconButton(
                  onPressed: () => createIssue(),
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                )
              ],
            ),
            body: const MyTopPage(),
          ),
        );
      }),
    );
  }
}
