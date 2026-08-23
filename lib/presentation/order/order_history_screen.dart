import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../domain/entities/order.dart';
import 'providers/order_provider.dart';

class OrderHistoryScreen
    extends ConsumerWidget {
  const OrderHistoryScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final orders = ref.watch(
      orderProvider,
    );

    final reversedOrders =
    orders.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
        ),
      ),
      body: reversedOrders.isEmpty
          ? const Center(
        child: Text(
          'No orders yet.',
        ),
      )
          : ListView.builder(
        itemCount:
        reversedOrders.length,
        itemBuilder:
            (context, index) {
          final order =
          reversedOrders[index];

          final isBuy =
              order.side ==
                  OrderSide.buy;

          return ListTile(
            leading: CircleAvatar(
              child: Icon(
                isBuy
                    ? Icons
                    .arrow_upward
                    : Icons
                    .arrow_downward,
              ),
            ),
            title: Text(
              '${isBuy ? 'BUY' : 'SELL'} '
                  '${order.symbol}',
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Qty: ${order.quantity}\n'
                  'Price: '
                  '${PriceFormatter.formatPaise(order.executionPricePaise)}',
            ),
            trailing: Text(
              PriceFormatter.formatPaise(
                order.orderValuePaise,
              ),
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}