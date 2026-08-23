import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/holding_local_storage.dart';
import '../../../domain/entities/holding.dart';
import '../../../main.dart';

class HoldingsNotifier
    extends Notifier<List<Holding>> {
  late final HoldingLocalStorage _storage;

  @override
  List<Holding> build() {
    _storage = ref.watch(
      holdingStorageProvider,
    );

    return _storage.getHoldings();
  }

  Holding? getHolding(String symbol) {
    for (final holding in state) {
      if (holding.symbol == symbol) {
        return holding;
      }
    }

    return null;
  }

  Future<void> addBuy({
    required String symbol,
    required int quantity,
    required int pricePaise,
  }) async {
    if (quantity <= 0 || pricePaise <= 0) {
      return;
    }

    final existing = getHolding(symbol);

    if (existing == null) {
      final holding = Holding(
        symbol: symbol,
        quantity: quantity,
        averagePricePaise: pricePaise,
      );

      await _storage.saveHolding(holding);

      state = [
        ...state,
        holding,
      ];

      return;
    }

    final oldQuantity = existing.quantity;
    final oldAverage =
        existing.averagePricePaise;

    final newQuantity =
        oldQuantity + quantity;

    final totalOldValue =
        oldQuantity * oldAverage;

    final totalNewValue =
        quantity * pricePaise;

    final newAverage =
        (totalOldValue + totalNewValue) ~/
            newQuantity;

    final updated = existing.copyWith(
      quantity: newQuantity,
      averagePricePaise: newAverage,
    );

    await _storage.saveHolding(updated);

    state = state.map((holding) {
      if (holding.symbol == symbol) {
        return updated;
      }

      return holding;
    }).toList();
  }

  Future<String?> sell({
    required String symbol,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return 'Quantity must be greater than zero.';
    }

    final existing = getHolding(symbol);

    if (existing == null) {
      return 'You do not hold $symbol.';
    }

    if (quantity > existing.quantity) {
      return 'You only hold ${existing.quantity} shares.';
    }

    final newQuantity =
        existing.quantity - quantity;

    if (newQuantity == 0) {
      await _storage.deleteHolding(symbol);

      state = state
          .where(
            (holding) =>
        holding.symbol != symbol,
      )
          .toList();

      return null;
    }

    final updated = existing.copyWith(
      quantity: newQuantity,
    );

    await _storage.saveHolding(updated);

    state = state.map((holding) {
      if (holding.symbol == symbol) {
        return updated;
      }

      return holding;
    }).toList();

    return null;
  }
}

final holdingsProvider =
NotifierProvider<
    HoldingsNotifier,
    List<Holding>>(
  HoldingsNotifier.new,
);