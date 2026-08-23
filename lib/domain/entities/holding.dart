import 'package:equatable/equatable.dart';

class Holding extends Equatable {
  final String symbol;
  final int quantity;
  final int averagePricePaise;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.averagePricePaise,
  });

  Holding copyWith({
    String? symbol,
    int? quantity,
    int? averagePricePaise,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      averagePricePaise:
      averagePricePaise ?? this.averagePricePaise,
    );
  }

  @override
  List<Object?> get props => [
    symbol,
    quantity,
    averagePricePaise,
  ];
}