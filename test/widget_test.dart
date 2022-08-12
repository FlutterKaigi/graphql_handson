// This is a basic widget test that tests just the good app code.

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_handson/main.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we have a forecast, or a managed failure.
    expect(find.textContaining('Flutter Demo Home Page'), findsOneWidget);
  });
}
