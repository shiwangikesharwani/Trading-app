import 'package:flutter_test/flutter_test.dart';

import 'package:trading_app/domain/entities/stock.dart';

void main() {
  group('Stock calculations', () {
    test(
      'calculates positive price change',
          () {
        final stock = Stock(
          symbol: 'RELIANCE',
          pricePaise: 150000,
          previousPricePaise: 145000,
        );

        expect(
          stock.changePaise,
          5000,
        );

        expect(
          stock.isUp,
          true,
        );

        expect(
          stock.isDown,
          false,
        );
      },
    );

    test(
      'calculates negative price change',
          () {
        final stock = Stock(
          symbol: 'TCS',
          pricePaise: 300000,
          previousPricePaise: 310000,
        );

        expect(
          stock.changePaise,
          -10000,
        );

        expect(
          stock.isDown,
          true,
        );

        expect(
          stock.isUp,
          false,
        );
      },
    );

    test(
      'calculates percentage change',
          () {
        final stock = Stock(
          symbol: 'INFY',
          pricePaise: 110000,
          previousPricePaise: 100000,
        );

        expect(
          stock.changePercent,
          closeTo(10.0, 0.001),
        );
      },
    );
  });
}