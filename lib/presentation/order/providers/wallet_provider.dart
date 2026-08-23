import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/wallet_local_storage.dart';
import '../../../main.dart';

class WalletNotifier extends Notifier<int> {
  late final WalletLocalStorage _storage;

  @override
  int build() {
    _storage = ref.watch(
      walletStorageProvider,
    );

    return _storage.getBalance();
  }

  Future<void> updateBalance(
      int newBalancePaise,
      ) async {
    await _storage.saveBalance(
      newBalancePaise,
    );

    state = newBalancePaise;
  }
}

final walletProvider =
NotifierProvider<WalletNotifier, int>(
  WalletNotifier.new,
);