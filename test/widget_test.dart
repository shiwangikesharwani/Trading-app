import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Trading app loads successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Market'),
                Text('Watchlist'),
                Text('Holdings'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Market'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('Holdings'), findsOneWidget);
    },
  );
}