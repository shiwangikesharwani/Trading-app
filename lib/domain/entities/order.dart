import 'package:equatable/equatable.dart';

enum OrderSide {
  buy,
  sell,
}

class Order extends Equatable {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final int executionPricePaise;
  final int orderValuePaise;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executionPricePaise,
    required this.orderValuePaise,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    symbol,
    side,
    quantity,
    executionPricePaise,
    orderValuePaise,
    createdAt,
  ];
}