import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final int balancePaise;

  const Wallet({
    required this.balancePaise,
  });

  Wallet copyWith({
    int? balancePaise,
  }) {
    return Wallet(
      balancePaise: balancePaise ?? this.balancePaise,
    );
  }

  @override
  List<Object?> get props => [
    balancePaise,
  ];
}