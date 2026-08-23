import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../market/providers/market_notifier.dart';
import '../order/order_ticket_screen.dart';
import 'providers/holdings_provider.dart';
import '../order/order_history_screen.dart';
import '../order/providers/wallet_provider.dart';

enum HoldingSort {
  pnl,
  symbol,
  currentValue,
}

class HoldingsScreen extends ConsumerStatefulWidget {
  const HoldingsScreen({
    super.key,
  });

  @override
  ConsumerState<HoldingsScreen> createState() =>
      _HoldingsScreenState();
}

class _HoldingsScreenState
    extends ConsumerState<HoldingsScreen> {
  HoldingSort sortBy = HoldingSort.pnl;

  @override
  Widget build(BuildContext context) {
    final holdings = ref.watch(
      holdingsProvider,
    );
    final walletBalance = ref.watch(
      walletProvider,
    );
    ref.watch(marketNotifierProvider);
    if (holdings.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Holdings'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'No holdings yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Buy stocks to see your portfolio here.',
              ),
            ],
          ),
        ),
      );
    }

    final rows = holdings.map((holding) {
      final stock = ref.watch(
        stockProvider(holding.symbol),
      );

      return HoldingViewData(
        holding: holding,
        ltpPaise:
        stock?.pricePaise ??
            holding.averagePricePaise,
      );
    }).toList();

    _sortRows(rows);

    final totalInvested = rows.fold<int>(
      0,
          (sum, item) =>
      sum +
          item.investedValuePaise,
    );

    final totalCurrentValue = rows.fold<int>(
      0,
          (sum, item) =>
      sum +
          item.currentValuePaise,
    );

    final totalPnl =
        totalCurrentValue - totalInvested;

    final totalPnlPercent =
    totalInvested == 0
        ? 0.0
        : (totalPnl / totalInvested) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holdings'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.receipt_long,
            ),
            tooltip: 'Order History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const OrderHistoryScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<HoldingSort>(
            initialValue: sortBy,
            onSelected: (value) {
              setState(() {
                sortBy = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: HoldingSort.pnl,
                child: Text(
                  'Sort by P&L',
                ),
              ),
              PopupMenuItem(
                value: HoldingSort.symbol,
                child: Text(
                  'Sort by Symbol',
                ),
              ),
              PopupMenuItem(
                value: HoldingSort.currentValue,
                child: Text(
                  'Sort by Current Value',
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            child: Card(
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance,
                ),
                title: const Text(
                  'Available Balance',
                ),
                trailing: Text(
                  PriceFormatter.formatPaise(
                    walletBalance,
                  ),
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          PortfolioSummaryCard(
            totalInvested:
            totalInvested,
            totalCurrentValue:
            totalCurrentValue,
            totalPnl:
            totalPnl,
            totalPnlPercent:
            totalPnlPercent,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) {
                return HoldingRow(
                  key: ValueKey(
                    rows[index].holding.symbol,
                  ),
                  holding: rows[index].holding,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sortRows(
      List<HoldingViewData> rows,
      ) {
    switch (sortBy) {
      case HoldingSort.pnl:
        rows.sort(
              (a, b) => b.pnlPaise.compareTo(
            a.pnlPaise,
          ),
        );
        break;

      case HoldingSort.symbol:
        rows.sort(
              (a, b) => a.holding.symbol.compareTo(
            b.holding.symbol,
          ),
        );
        break;

      case HoldingSort.currentValue:
        rows.sort(
              (a, b) =>
              b.currentValuePaise.compareTo(
                a.currentValuePaise,
              ),
        );
        break;
    }
  }
}

class HoldingViewData {
  final dynamic holding;
  final int ltpPaise;

  HoldingViewData({
    required this.holding,
    required this.ltpPaise,
  });

  int get investedValuePaise =>
      holding.quantity *
          holding.averagePricePaise;

  int get currentValuePaise =>
      holding.quantity *
          ltpPaise;

  int get pnlPaise =>
      currentValuePaise -
          investedValuePaise;

  double get pnlPercent {
    if (investedValuePaise == 0) {
      return 0;
    }

    return (pnlPaise /
        investedValuePaise) *
        100;
  }
}

class PortfolioSummaryCard
    extends StatelessWidget {
  final int totalInvested;
  final int totalCurrentValue;
  final int totalPnl;
  final double totalPnlPercent;

  const PortfolioSummaryCard({
    super.key,
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalPnl,
    required this.totalPnlPercent,
  });

  @override
  Widget build(BuildContext context) {
    final pnlColor = totalPnl > 0
        ? Colors.green
        : totalPnl < 0
        ? Colors.red
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row(
              'Total Invested',
              PriceFormatter.formatPaise(
                totalInvested,
              ),
            ),
            const SizedBox(height: 10),
            _row(
              'Current Value',
              PriceFormatter.formatPaise(
                totalCurrentValue,
              ),
            ),
            const Divider(),
            _row(
              'Total P&L',
              '${PriceFormatter.formatChange(totalPnl)} '
                  '(${PriceFormatter.formatPercent(totalPnlPercent)})',
              valueColor: pnlColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
      String title,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class HoldingRow
    extends ConsumerWidget {
  final dynamic holding;

  const HoldingRow({
    super.key,
    required this.holding,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final stock = ref.watch(
      stockProvider(
        holding.symbol,
      ),
    );

    final ltpPaise =
        stock?.pricePaise ??
            holding.averagePricePaise;

    final investedValuePaise =
        holding.quantity *
            holding.averagePricePaise;

    final currentValuePaise =
        holding.quantity *
            ltpPaise;

    final pnlPaise =
        currentValuePaise -
            investedValuePaise;

    final pnlPercent =
    investedValuePaise == 0
        ? 0.0
        : (pnlPaise /
        investedValuePaise) *
        100;

    final pnlColor =
    pnlPaise > 0
        ? Colors.green
        : pnlPaise < 0
        ? Colors.red
        : Colors.grey;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OrderTicketScreen(
                  symbol: holding.symbol,
                ),
          ),
        );
      },
      title: Row(
        children: [
          Expanded(
            child: Text(
              holding.symbol,
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
          Text(
            PriceFormatter.formatPaise(
              ltpPaise,
            ),
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(
            'Qty: ${holding.quantity}   '
                'Avg: ${PriceFormatter.formatPaise(holding.averagePricePaise)}',
          ),
          const SizedBox(height: 4),
          Text(
            'Value: '
                '${PriceFormatter.formatPaise(currentValuePaise)}',
          ),
          const SizedBox(height: 4),
          Text(
            'P&L: '
                '${PriceFormatter.formatChange(pnlPaise)} '
                '(${PriceFormatter.formatPercent(pnlPercent)})',
            style: TextStyle(
              color: pnlColor,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}