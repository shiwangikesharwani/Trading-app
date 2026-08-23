import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:trading_app/main.dart';

void main() {
  testWidgets(
    'Trading app loads successfully',
        (WidgetTester tester) async {
      final directory = await getTemporaryDirectory();

      Hive.init(directory.path);

      final app = await createAppForTest();

      await tester.pumpWidget(app);

      await tester.pump();

      expect(find.text('Market'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('Holdings'), findsOneWidget);
    },
  );
}