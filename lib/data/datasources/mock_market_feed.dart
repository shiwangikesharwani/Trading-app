import 'dart:async';
import 'dart:math';

import '../../core/constants/stock_constants.dart';

class PriceTick {
  final String symbol;
  final int previousPricePaise;
  final int pricePaise;

  const PriceTick({
    required this.symbol,
    required this.previousPricePaise,
    required this.pricePaise,
  });

  int get changePaise =>
      pricePaise - previousPricePaise;

  double get changePercent {
    if (previousPricePaise == 0) {
      return 0;
    }

    return (changePaise / previousPricePaise) * 100;
  }
}

class MockMarketFeed {
  final Random _random = Random();

  final Map<String, int> _prices = {
    ...StockConstants.startingPricesPaise,
  };

  final StreamController<PriceTick>
  _controller =
  StreamController<PriceTick>.broadcast();

  Timer? _timer;

  int ticksPerSecondPerStock = 1;

  Stream<PriceTick> get ticks =>
      _controller.stream;

  Map<String, int> get currentPrices =>
      Map.unmodifiable(_prices);

  void start({
    int ticksPerSecondPerStock = 1,
  }) {
    stop();

    this.ticksPerSecondPerStock =
        ticksPerSecondPerStock;

    final intervalMilliseconds =
    (1000 / ticksPerSecondPerStock)
        .round();

    _timer = Timer.periodic(
      Duration(
        milliseconds: intervalMilliseconds,
      ),
          (_) {
        _emitAllStockTicks();
      },
    );
  }

  void _emitAllStockTicks() {
    for (final symbol
    in StockConstants.symbols) {
      _emitTick(symbol);
    }
  }

  void _emitTick(String symbol) {
    final oldPrice = _prices[symbol]!;

    // Random movement between -0.10% and +0.10%.
    final movementPercent =
        (_random.nextDouble() * 0.20) -
            0.10;

    final movement =
    (oldPrice *
        movementPercent /
        100)
        .round();

    final safeMovement =
    movement == 0
        ? (_random.nextBool() ? 1 : -1)
        : movement;

    final newPrice = max(
      1,
      oldPrice + safeMovement,
    );

    _prices[symbol] = newPrice;

    _controller.add(
      PriceTick(
        symbol: symbol,
        previousPricePaise: oldPrice,
        pricePaise: newPrice,
      ),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}