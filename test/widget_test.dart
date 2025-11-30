import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vocasafe/main.dart';

void main() {
  testWidgets('VocaSafe app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VocaSafeApp());

    // Verify that the app loads
    expect(find.text('VocaSafe'), findsOneWidget);
  });
}
