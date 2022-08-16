// This is a basic widget test that tests just the good app code.

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_handson/pages/index.dart';

void main() {
  group('App', () {
    testWidgets('CardItem test', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CardItem(
        title: '_graphql_handson',
        message: 'ANSWER REPOSITORY - FlutterKaigi 2022 workshop event',
        url: 'https://github.com/FlutterKaigi/_graphql_handson',
        updatedAt: '2022-08-13T09:35:44Z',
      ));

      // Verify that we have a forecast, or a managed failure.
      expect(find.textContaining('_graphql_handson'), findsOneWidget);
      expect(
          find.textContaining(
              'ANSWER REPOSITORY - FlutterKaigi 2022 workshop event'),
          findsOneWidget);
      expect(find.textContaining('2022-08-13T09:35:44Z'), findsOneWidget);
    });
  });
}
