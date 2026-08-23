import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/holding.dart';

class HoldingLocalStorage {
  static const String boxName = 'holdings';

  Future<void> init() async {
    await Hive.openBox<String>(boxName);
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> saveHolding(
      Holding holding,
      ) async {
    final data = jsonEncode({
      'symbol': holding.symbol,
      'quantity': holding.quantity,
      'averagePricePaise':
      holding.averagePricePaise,
    });

    await _box.put(
      holding.symbol,
      data,
    );
  }

  Future<void> deleteHolding(
      String symbol,
      ) async {
    await _box.delete(symbol);
  }

  List<Holding> getHoldings() {
    return _box.values.map((value) {
      final json = jsonDecode(value);

      return Holding(
        symbol: json['symbol'] as String,
        quantity: json['quantity'] as int,
        averagePricePaise:
        json['averagePricePaise'] as int,
      );
    }).toList();
  }
}