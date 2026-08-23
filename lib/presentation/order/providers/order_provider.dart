import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/datasources/order_local_storage.dart';
import '../../../domain/entities/order.dart';
import '../../../main.dart';
import '../../holdings/providers/holdings_provider.dart';
import 'wallet_provider.dart';

class OrderNotifier extends Notifier<List<Order>> {
  late final OrderLocalStorage _storage;

  final Uuid _uuid = const Uuid();

  @override
  List<Order> build() {
    _storage = ref.watch(
      orderStorageProvider,
    );

    return _storage.getOrders();
  }

  Future<String?> placeBuyOrder({
    required String symbol,
    required int quantity,
    required int executionPricePaise,
  }) async {
    // Quantity validation
    if (quantity <= 0) {
      return 'Enter a valid whole quantity.';
    }

    // Market price validation
    if (executionPricePaise <= 0) {
      return 'Invalid market price.';
    }

    // Calculate order value using paise
    final orderValuePaise =
        quantity * executionPricePaise;

    // Check available balance
    final currentBalance =
    ref.read(walletProvider);

    if (orderValuePaise > currentBalance) {
      return 'Insufficient balance.';
    }

    // Create order
    final order = Order(
      id: _uuid.v4(),
      symbol: symbol,
      side: OrderSide.buy,
      quantity: quantity,
      executionPricePaise:
      executionPricePaise,
      orderValuePaise:
      orderValuePaise,
      createdAt: DateTime.now(),
    );

    // Persist order
    await _storage.saveOrder(order);

    // Deduct money from wallet
    await ref
        .read(walletProvider.notifier)
        .updateBalance(
      currentBalance -
          orderValuePaise,
    );

    // Add/update holding
    await ref
        .read(holdingsProvider.notifier)
        .addBuy(
      symbol: symbol,
      quantity: quantity,
      pricePaise:
      executionPricePaise,
    );

    // Update order state
    state = [
      ...state,
      order,
    ];

    return null;
  }

  Future<String?> placeSellOrder({
    required String symbol,
    required int quantity,
    required int executionPricePaise,
  }) async {
    // Quantity validation
    if (quantity <= 0) {
      return 'Enter a valid whole quantity.';
    }

    // Market price validation
    if (executionPricePaise <= 0) {
      return 'Invalid market price.';
    }

    // Check holding quantity and
    // reduce the holding
    final holdingError = await ref
        .read(holdingsProvider.notifier)
        .sell(
      symbol: symbol,
      quantity: quantity,
    );

    if (holdingError != null) {
      return holdingError;
    }

    // Calculate order value
    final orderValuePaise =
        quantity * executionPricePaise;

    // Create order
    final order = Order(
      id: _uuid.v4(),
      symbol: symbol,
      side: OrderSide.sell,
      quantity: quantity,
      executionPricePaise:
      executionPricePaise,
      orderValuePaise:
      orderValuePaise,
      createdAt: DateTime.now(),
    );

    // Persist order
    await _storage.saveOrder(order);

    // Add sale amount to wallet
    final currentBalance =
    ref.read(walletProvider);

    await ref
        .read(walletProvider.notifier)
        .updateBalance(
      currentBalance +
          orderValuePaise,
    );

    // Update order state
    state = [
      ...state,
      order,
    ];

    return null;
  }
}

final orderProvider =
NotifierProvider<
    OrderNotifier,
    List<Order>>(
  OrderNotifier.new,
);