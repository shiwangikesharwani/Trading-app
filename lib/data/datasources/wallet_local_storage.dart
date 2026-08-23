import 'package:hive_flutter/hive_flutter.dart';

class WalletLocalStorage {
  static const String boxName = 'wallet';

  Future<void> init() async {
    await Hive.openBox<int>(boxName);
  }

  Box<int> get _box => Hive.box<int>(boxName);

  int getBalance() {
    return _box.get(
      'balancePaise',
      defaultValue: 10000000,
    ) ??
        10000000;
  }

  Future<void> saveBalance(
      int balancePaise,
      ) async {
    await _box.put(
      'balancePaise',
      balancePaise,
    );
  }
}