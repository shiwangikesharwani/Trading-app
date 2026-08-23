import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../market/providers/market_notifier.dart';
import 'providers/order_provider.dart';
import 'providers/wallet_provider.dart';
import '../holdings/providers/holdings_provider.dart';

class OrderTicketScreen extends ConsumerStatefulWidget {
  final String symbol;

  const OrderTicketScreen({
    super.key,
    required this.symbol,
  });

  @override
  ConsumerState<OrderTicketScreen> createState() =>
      _OrderTicketScreenState();
}

class _OrderTicketScreenState
    extends ConsumerState<OrderTicketScreen> {
  final quantityController =
  TextEditingController();

  bool isBuy = true;

  String? validationError;

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(
      stockProvider(widget.symbol),
    );

    final balance = ref.watch(
      walletProvider,
    );
    final holding = ref.watch(
      holdingsProvider.select(
            (holdings) {
          for (final item in holdings) {
            if (item.symbol == widget.symbol) {
              return item;
            }
          }

          return null;
        },
      ),
    );


    if (stock == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order'),
        ),
        body: const Center(
          child: Text('Stock not found'),
        ),
      );
    }

    final quantity =
        int.tryParse(
          quantityController.text.trim(),
        ) ??
            0;

    final orderValue =
        quantity * stock.pricePaise;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${isBuy ? 'Buy' : 'Sell'} ${widget.symbol}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            _priceCard(
              stock.pricePaise,
            ),

            const SizedBox(height: 20),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('BUY'),
                  icon: Icon(
                    Icons.arrow_upward,
                  ),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('SELL'),
                  icon: Icon(
                    Icons.arrow_downward,
                  ),
                ),
              ],
              selected: {
                isBuy,
              },
              onSelectionChanged: (selection) {
                setState(() {
                  isBuy = selection.first;
                  validationError = null;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: quantityController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {
                  validationError = null;
                });
              },
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity',
                border:
                const OutlineInputBorder(),
                errorText: validationError,
              ),
            ),

            const SizedBox(height: 20),

            _infoRow(
              'Order Value',
              PriceFormatter.formatPaise(
                orderValue,
              ),
            ),

            const SizedBox(height: 8),

            _infoRow(
              'Available Balance',
              PriceFormatter.formatPaise(
                balance,
              ),
            ),
            if (!isBuy)
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Available quantity: '
                        '${holding?.quantity ?? 0}',
                  ),
                ),
              ),
            const Spacer(),

            FilledButton(
              onPressed: () {
                _submit(
                  stock.pricePaise,
                );
              },
              child: Text(
                'PLACE ${isBuy ? 'BUY' : 'SELL'} ORDER',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceCard(
      int pricePaise,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.symbol,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Current LTP',
            ),
            const SizedBox(height: 4),
            Text(
              PriceFormatter.formatPaise(
                pricePaise,
              ),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      String title,
      String value,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _submit(
      int currentPricePaise,
      ) async {
    final rawQuantity =
    quantityController.text.trim();

    if (rawQuantity.isEmpty) {
      setState(() {
        validationError =
        'Quantity is required.';
      });
      return;
    }

    final quantity =
    int.tryParse(rawQuantity);

    if (quantity == null ||
        quantity <= 0) {
      setState(() {
        validationError =
        'Enter a valid quantity greater than zero.';
      });
      return;
    }

    String? error;

    if (isBuy) {
      error = await ref
          .read(orderProvider.notifier)
          .placeBuyOrder(
        symbol: widget.symbol,
        quantity: quantity,
        executionPricePaise:
        currentPricePaise,
      );
    } else {
      error = await ref
          .read(orderProvider.notifier)
          .placeSellOrder(
        symbol: widget.symbol,
        quantity: quantity,
        executionPricePaise:
        currentPricePaise,
      );
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        validationError = error;
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          symbol: widget.symbol,
          isBuy: isBuy,
          quantity: quantity,
          executionPricePaise:
          currentPricePaise,
        ),
      ),
    );
  }
}

class OrderConfirmationScreen
    extends StatelessWidget {
  final String symbol;
  final bool isBuy;
  final int quantity;
  final int executionPricePaise;

  const OrderConfirmationScreen({
    super.key,
    required this.symbol,
    required this.isBuy,
    required this.quantity,
    required this.executionPricePaise,
  });

  @override
  Widget build(BuildContext context) {
    final orderValue =
        quantity * executionPricePaise;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Confirmation',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              Text(
                '${isBuy ? 'Buy' : 'Sell'} Order Successful',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                symbol,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quantity: $quantity',
              ),
              Text(
                'Execution Price: '
                    '${PriceFormatter.formatPaise(executionPricePaise)}',
              ),
              Text(
                'Order Value: '
                    '${PriceFormatter.formatPaise(orderValue)}',
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },
                child: const Text(
                  'DONE',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}