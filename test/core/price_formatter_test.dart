import 'package:flutter_test/flutter_test.dart';

import 'package:trading_app/core/utils/price_formatter.dart';

void main() {
  group('PriceFormatter', () {
    test(
      'formats paise into rupees',
          () {
        expect(
          PriceFormatter.formatPaise(145025),
          '₹1450.25',
        );
      },
    );

    test(
      'formats zero correctly',
          () {
        expect(
          PriceFormatter.formatPaise(0),
          '₹0.00',
        );
      },
    );

    test(
      'formats positive change',
          () {
        expect(
          PriceFormatter.formatChange(12550),
          '+₹125.50',
        );
      },
    );

    test(
      'formats negative change',
          () {
        expect(
          PriceFormatter.formatChange(-12550),
          '-₹125.50',
        );
      },
    );
  });
}