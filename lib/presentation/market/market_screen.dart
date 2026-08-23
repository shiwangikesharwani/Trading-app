import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/stock_constants.dart';
import '../../core/utils/price_formatter.dart';
import 'providers/market_notifier.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Market',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Tick Rate',
            onSelected: (rate) {
              ref
                  .read(
                marketNotifierProvider.notifier,
              )
                  .setTickRate(rate);

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    '$rate tick/sec per stock',
                  ),
                  duration:
                  const Duration(seconds: 1),
                ),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 1,
                child: Text(
                  'Normal • 1 tick/sec',
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(
                  'Fast • 2 ticks/sec',
                ),
              ),
              PopupMenuItem(
                value: 5,
                child: Text(
                  'Stress • 5 ticks/sec',
                ),
              ),
              PopupMenuItem(
                value: 10,
                child: Text(
                  'Extreme • 10 ticks/sec',
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: StockConstants.symbols.length,
        itemBuilder: (context, index) {
          final symbol = StockConstants.symbols[index];

          return StockRow(key: ValueKey(symbol), symbol: symbol);
        },
      ),
    );
  }
}

class StockRow extends ConsumerStatefulWidget {
  final String symbol;

  const StockRow({super.key, required this.symbol});

  @override
  ConsumerState<StockRow> createState() => _StockRowState();
}

class _StockRowState extends ConsumerState<StockRow> {
  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(stockProvider(widget.symbol));

    if (stock == null) {
      return const SizedBox.shrink();
    }

    final changeColor = stock.isUp
        ? Colors.green
        : stock.isDown
        ? Colors.red
        : Colors.grey;

    return TweenAnimationBuilder<double>(
      key: ValueKey('${stock.pricePaise}_${stock.previousPricePaise}'),
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        final flashColor = stock.isUp
            ? Colors.green.withValues(alpha: value * 0.18)
            : stock.isDown
            ? Colors.red.withValues(alpha: value * 0.18)
            : Colors.transparent;

        return Container(
          decoration: BoxDecoration(color: flashColor),
          child: ListTile(
            title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(PriceFormatter.formatChange(stock.changePaise), style: TextStyle(color: changeColor)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(PriceFormatter.formatPaise(stock.pricePaise), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(PriceFormatter.formatPercent(stock.changePercent), style: TextStyle(color: changeColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}
