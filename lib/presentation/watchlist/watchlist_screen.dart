import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trading_app/presentation/order/order_ticket_screen.dart';

import '../../core/constants/stock_constants.dart';
import '../../core/utils/price_formatter.dart';
import '../market/providers/market_notifier.dart';
import 'providers/watchlist_notifier.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  String? selectedWatchlistId;

  @override
  Widget build(BuildContext context) {
    final watchlists = ref.watch(watchlistProvider);

    if (watchlists.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Watchlists'),
          actions: [IconButton(onPressed: _createWatchlist, icon: const Icon(Icons.add))],
        ),
        body: _emptyState(),
      );
    }

    final selectedId = selectedWatchlistId ?? watchlists.first.id;

    final selected = watchlists.firstWhere((item) => item.id == selectedId, orElse: () => watchlists.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlists'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'create') {
                _createWatchlist();
              } else if (value == 'rename') {
                _renameWatchlist(selected);
              } else if (value == 'delete') {
                _deleteWatchlist(selected);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'create', child: Text('Create Watchlist')),
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _watchlistSelector(watchlists, selected.id),
          Expanded(child: selected.symbols.isEmpty ? _emptyWatchlist() : _stockList(selected)),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _addStock(selected.id), child: const Icon(Icons.add)),
    );
  }

  Widget _watchlistSelector(List watchlists, String selectedId) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<String>(
        initialValue: selectedId,
        decoration: const InputDecoration(labelText: 'Watchlist', border: OutlineInputBorder()),
        items: watchlists.map((watchlist) {
          return DropdownMenuItem<String>(value: watchlist.id, child: Text(watchlist.name));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedWatchlistId = value;
          });
        },
      ),
    );
  }

  Widget _stockList(dynamic watchlist) {
    return ReorderableListView.builder(
      itemCount: watchlist.symbols.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(watchlistProvider.notifier).reorderStock(watchlist.id, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final symbol = watchlist.symbols[index];

        return StockWatchlistRow(
          key: ValueKey(symbol),
          symbol: symbol,
          onRemove: () {
            ref.read(watchlistProvider.notifier).removeStock(watchlist.id, symbol);
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 64),
          const SizedBox(height: 16),
          const Text('No watchlists yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _createWatchlist, child: const Text('Create Watchlist')),
        ],
      ),
    );
  }

  Widget _emptyWatchlist() {
    return const Center(child: Text('This watchlist is empty.\nTap + to add stocks.', textAlign: TextAlign.center));
  }

  Future<void> _createWatchlist() async {
    final name = await _showNameDialog(title: 'Create Watchlist');

    if (name == null) return;

    await ref.read(watchlistProvider.notifier).createWatchlist(name);
  }

  Future<void> _renameWatchlist(dynamic watchlist) async {
    final name = await _showNameDialog(title: 'Rename Watchlist', initialValue: watchlist.name);

    if (name == null) return;

    await ref.read(watchlistProvider.notifier).renameWatchlist(watchlist.id, name);
  }

  Future<void> _deleteWatchlist(dynamic watchlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Watchlist?'),
          content: Text('Delete "${watchlist.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(watchlistProvider.notifier).deleteWatchlist(watchlist.id);

    setState(() {
      selectedWatchlistId = null;
    });
  }

  Future<void> _addStock(String watchlistId) async {
    final watchlists = ref.read(watchlistProvider);

    final watchlist = watchlists.firstWhere((item) => item.id == watchlistId);

    final availableStocks = StockConstants.symbols.where((symbol) => !watchlist.symbols.contains(symbol)).toList();

    if (availableStocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All stocks are already in this watchlist.')));

      return;
    }

    final symbol = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add Stock'),
          children: availableStocks.map((symbol) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, symbol);
              },
              child: Text(symbol),
            );
          }).toList(),
        );
      },
    );

    if (symbol == null) return;

    await ref.read(watchlistProvider.notifier).addStock(watchlistId, symbol);
  }

  Future<String?> _showNameDialog({required String title, String? initialValue}) async {
    final controller = TextEditingController(text: initialValue ?? '');

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Watchlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class StockWatchlistRow extends ConsumerWidget {
  final String symbol;
  final VoidCallback onRemove;

  const StockWatchlistRow({super.key, required this.symbol, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockProvider(symbol));

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
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        final flashColor = stock.isUp
            ? Colors.green.withValues(
            alpha:value * 0.15)
            : stock.isDown
            ? Colors.red.withValues(
            alpha:value * 0.15)
            : Colors.transparent;

        return Container(
          color: flashColor,
          child: ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTicketScreen(symbol: symbol)));
            },
            title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(PriceFormatter.formatChange(stock.changePaise), style: TextStyle(color: changeColor)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(PriceFormatter.formatPaise(stock.pricePaise)),
                    Text(PriceFormatter.formatPercent(stock.changePercent), style: TextStyle(color: changeColor)),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'remove') {
                      onRemove();
                    }
                  },
                  itemBuilder: (context) => const [PopupMenuItem(value: 'remove', child: Text('Remove'))],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
