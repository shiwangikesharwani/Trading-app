import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/domain/entities/order.dart';

void main() {
  group('Order tests', () {
    test('creates buy order correctly', () {
      final createdAt = DateTime(2026, 8, 22);

      final order = Order(
        id: 'order_1',
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        quantity: 10,
        executionPricePaise: 145000,
        orderValuePaise: 1450000,
        createdAt: createdAt,
      );

      expect(order.id, 'order_1');
      expect(order.symbol, 'RELIANCE');
      expect(order.side, OrderSide.buy);
      expect(order.quantity, 10);
      expect(order.executionPricePaise, 145000);
      expect(order.orderValuePaise, 1450000);
      expect(order.createdAt, createdAt);
    });

    test('creates sell order correctly', () {
      final order = Order(
        id: 'order_2',
        symbol: 'TCS',
        side: OrderSide.sell,
        quantity: 5,
        executionPricePaise: 300000,
        orderValuePaise: 1500000,
        createdAt: DateTime(2026, 8, 22),
      );

      expect(order.side, OrderSide.sell);
      expect(order.symbol, 'TCS');
      expect(order.quantity, 5);
    });

    test('two identical orders are equal', () {
      final date = DateTime(2026, 8, 22);

      final order1 = Order(
        id: 'order_1',
        symbol: 'INFY',
        side: OrderSide.buy,
        quantity: 10,
        executionPricePaise: 100000,
        orderValuePaise: 1000000,
        createdAt: date,
      );

      final order2 = Order(
        id: 'order_1',
        symbol: 'INFY',
        side: OrderSide.buy,
        quantity: 10,
        executionPricePaise: 100000,
        orderValuePaise: 1000000,
        createdAt: date,
      );

      expect(order1, order2);
    });
  });
}