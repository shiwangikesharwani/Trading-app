class StockConstants {
  StockConstants._();

  static const Map<String, int> startingPricesPaise = {
    'RELIANCE': 145000,
    'TCS': 320000,
    'INFY': 155000,
    'HDFCBANK': 175000,
    'ICICIBANK': 125000,
    'SBIN': 85000,
    'ITC': 52000,
    'LT': 365000,
    'BHARTIARTL': 185000,
    'AXISBANK': 118000,
  };

  static List<String> get symbols =>
      startingPricesPaise.keys.toList(growable: false);
}