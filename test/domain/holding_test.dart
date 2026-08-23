import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/domain/entities/holding.dart';

void main() {
  group('Holding tests', () {
    test('creates holding with correct values', () {
      const holding = Holding(
        symbol: 'RELIANCE',
        quantity: 10,
        averagePricePaise: 145000,
      );

      expect(holding.symbol, 'RELIANCE');
      expect(holding.quantity, 10);
      expect(holding.averagePricePaise, 145000);
    });

    test('copyWith updates quantity only', () {
      const holding = Holding(
        symbol: 'RELIANCE',
        quantity: 10,
        averagePricePaise: 145000,
      );

      final updatedHolding = holding.copyWith(
        quantity: 20,
      );

      expect(updatedHolding.symbol, 'RELIANCE');
      expect(updatedHolding.quantity, 20);
      expect(updatedHolding.averagePricePaise, 145000);
    });

    test('two identical holdings are equal', () {
      const holding1 = Holding(
        symbol: 'TCS',
        quantity: 5,
        averagePricePaise: 300000,
      );

      const holding2 = Holding(
        symbol: 'TCS',
        quantity: 5,
        averagePricePaise: 300000,
      );

      expect(holding1, holding2);
    });
  });
}