class PriceFormatter {
  PriceFormatter._();

  static String formatPaise(int paise) {
    final rupees = paise ~/ 100;
    final decimal = (paise % 100).abs();

    return '₹$rupees.${decimal.toString().padLeft(2, '0')}';
  }

  static String formatChange(int paise) {
    final sign = paise >= 0 ? '+' : '-';
    final value = paise.abs();

    final rupees = value ~/ 100;
    final decimal = value % 100;

    return '$sign₹$rupees.${decimal.toString().padLeft(2, '0')}';
  }

  static String formatPercent(double value) {
    final sign = value >= 0 ? '+' : '';

    return '$sign${value.toStringAsFixed(2)}%';
  }
}