import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/order.dart';

class OrderLocalStorage {
  static const String boxName = 'orders';

  Future<void> init() async {
    await Hive.openBox<String>(boxName);
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> saveOrder(
      Order order,
      ) async {
    final data = jsonEncode({
      'id': order.id,
      'symbol': order.symbol,
      'side': order.side.name,
      'quantity': order.quantity,
      'executionPricePaise':
      order.executionPricePaise,
      'orderValuePaise':
      order.orderValuePaise,
      'createdAt':
      order.createdAt.toIso8601String(),
    });

    await _box.put(
      order.id,
      data,
    );
  }

  List<Order> getOrders() {
    return _box.values.map((value) {
      final json = jsonDecode(value);

      return Order(
        id: json['id'],
        symbol: json['symbol'],
        side: json['side'] == 'buy'
            ? OrderSide.buy
            : OrderSide.sell,
        quantity: json['quantity'],
        executionPricePaise:
        json['executionPricePaise'],
        orderValuePaise:
        json['orderValuePaise'],
        createdAt:
        DateTime.parse(json['createdAt']),
      );
    }).toList();
  }
}