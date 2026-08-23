import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/watchlist.dart';

class WatchlistLocalStorage {
  static const String boxName = 'watchlists';

  Future<void> init() async {
    await Hive.openBox<String>(boxName);
  }

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> saveWatchlist(
      Watchlist watchlist,
      ) async {
    final data = jsonEncode({
      'id': watchlist.id,
      'name': watchlist.name,
      'symbols': watchlist.symbols,
    });

    await _box.put(
      watchlist.id,
      data,
    );
  }

  Future<void> deleteWatchlist(
      String id,
      ) async {
    await _box.delete(id);
  }

  List<Watchlist> getWatchlists() {
    return _box.values.map((value) {
      final json = jsonDecode(value);

      return Watchlist(
        id: json['id'] as String,
        name: json['name'] as String,
        symbols: List<String>.from(
          json['symbols'] as List,
        ),
      );
    }).toList();
  }
}