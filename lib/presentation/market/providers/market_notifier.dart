import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/mock_market_feed.dart';
import '../../../domain/entities/stock.dart';

class MarketNotifier
    extends Notifier<Map<String, Stock>> {
  MockMarketFeed? _feed;

  StreamSubscription<PriceTick>?
  _subscription;

  @override
  Map<String, Stock> build() {
    _feed = MockMarketFeed();

    final initialState =
    <String, Stock>{};

    for (final entry
    in _feed!.currentPrices.entries) {
      initialState[entry.key] = Stock(
        symbol: entry.key,
        pricePaise: entry.value,
        previousPricePaise:
        entry.value,
      );
    }

    _subscription =
        _feed!.ticks.listen(_handleTick);

    _feed!.start(
      ticksPerSecondPerStock: 1,
    );

    ref.onDispose(() {
      _subscription?.cancel();
      _feed?.dispose();
    });

    return initialState;
  }

  void _handleTick(
      PriceTick tick,
      ) {
    final current =
    state[tick.symbol];

    if (current == null) {
      return;
    }

    // Only replace the affected stock.
    state = {
      ...state,
      tick.symbol: Stock(
        symbol: tick.symbol,
        pricePaise: tick.pricePaise,
        previousPricePaise:
        tick.previousPricePaise,
      ),
    };
  }

  void setTickRate(
      int ticksPerSecondPerStock,
      ) {
    _feed?.start(
      ticksPerSecondPerStock:
      ticksPerSecondPerStock,
    );
  }

  Stock? getStock(
      String symbol,
      ) {
    return state[symbol];
  }
}

final marketNotifierProvider =
NotifierProvider<
    MarketNotifier,
    Map<String, Stock>>(
  MarketNotifier.new,
);

final stockProvider =
Provider.family<Stock?, String>(
      (ref, symbol) {
    return ref.watch(
      marketNotifierProvider.select(
            (stocks) => stocks[symbol],
      ),
    );
  },
);