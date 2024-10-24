import 'package:flutter_test/flutter_test.dart';

import 'package:lightbluesky/main.dart';

// TODO: Implement tests
void main() {
  testWidgets('Base App', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
  });
}
