import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/datasources/watchlist_local_storage.dart';
import '../../../domain/entities/watchlist.dart';
import '../../../main.dart';

class WatchlistNotifier
    extends Notifier<List<Watchlist>> {
  late final WatchlistLocalStorage _storage;

  final Uuid _uuid = const Uuid();

  @override
  List<Watchlist> build() {
    _storage = ref.watch(
      watchlistStorageProvider,
    );

    return _storage.getWatchlists();
  }

  Future<void> createWatchlist(
      String name,
      ) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return;

    final watchlist = Watchlist(
      id: _uuid.v4(),
      name: trimmedName,
      symbols: const [],
    );

    await _storage.saveWatchlist(
      watchlist,
    );

    state = [
      ...state,
      watchlist,
    ];
  }

  Future<void> renameWatchlist(
      String id,
      String name,
      ) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return;

    final index = state.indexWhere(
          (item) => item.id == id,
    );

    if (index == -1) return;

    final updated = state[index].copyWith(
      name: trimmedName,
    );

    await _storage.saveWatchlist(
      updated,
    );

    final newState = [...state];

    newState[index] = updated;

    state = newState;
  }

  Future<void> deleteWatchlist(
      String id,
      ) async {
    await _storage.deleteWatchlist(id);

    state = state
        .where(
          (watchlist) => watchlist.id != id,
    )
        .toList();
  }

  Future<void> addStock(
      String watchlistId,
      String symbol,
      ) async {
    final index = state.indexWhere(
          (item) => item.id == watchlistId,
    );

    if (index == -1) return;

    final watchlist = state[index];

    if (watchlist.symbols.contains(symbol)) {
      return;
    }

    final updated = watchlist.copyWith(
      symbols: [
        ...watchlist.symbols,
        symbol,
      ],
    );

    await _storage.saveWatchlist(
      updated,
    );

    final newState = [...state];

    newState[index] = updated;

    state = newState;
  }

  Future<void> removeStock(
      String watchlistId,
      String symbol,
      ) async {
    final index = state.indexWhere(
          (item) => item.id == watchlistId,
    );

    if (index == -1) return;

    final watchlist = state[index];

    final updated = watchlist.copyWith(
      symbols: watchlist.symbols
          .where((item) => item != symbol)
          .toList(),
    );

    await _storage.saveWatchlist(
      updated,
    );

    final newState = [...state];

    newState[index] = updated;

    state = newState;
  }

  Future<void> reorderStock(
      String watchlistId,
      int oldIndex,
      int newIndex,
      ) async {
    final index = state.indexWhere(
          (item) => item.id == watchlistId,
    );

    if (index == -1) return;

    final watchlist = state[index];

    final symbols = [
      ...watchlist.symbols,
    ];

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final symbol = symbols.removeAt(oldIndex);

    symbols.insert(
      newIndex,
      symbol,
    );

    final updated = watchlist.copyWith(
      symbols: symbols,
    );

    await _storage.saveWatchlist(
      updated,
    );

    final newState = [...state];

    newState[index] = updated;

    state = newState;
  }
}

final watchlistProvider = NotifierProvider<
    WatchlistNotifier,
    List<Watchlist>>(
  WatchlistNotifier.new,
);