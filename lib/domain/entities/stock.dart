import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final String symbol;
  final int pricePaise;
  final int previousPricePaise;

  const Stock({
    required this.symbol,
    required this.pricePaise,
    required this.previousPricePaise,
  });

  int get changePaise => pricePaise - previousPricePaise;

  double get changePercent {
    if (previousPricePaise == 0) return 0;

    return (changePaise / previousPricePaise) * 100;
  }

  bool get isUp => changePaise > 0;

  bool get isDown => changePaise < 0;

  @override
  List<Object?> get props => [
    symbol,
    pricePaise,
    previousPricePaise,
  ];
}