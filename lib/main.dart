import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/datasources/watchlist_local_storage.dart';
import 'presentation/market/market_screen.dart';
import 'presentation/watchlist/watchlist_screen.dart';
import 'data/datasources/order_local_storage.dart';
import 'data/datasources/wallet_local_storage.dart';
import 'data/datasources/holding_local_storage.dart';
import 'presentation/holdings/holdings_screen.dart';

final watchlistStorageProvider =
Provider<WatchlistLocalStorage>((ref) {
  throw UnimplementedError();
});

final walletStorageProvider =
Provider<WalletLocalStorage>((ref) {
  throw UnimplementedError();
});

final orderStorageProvider =
Provider<OrderLocalStorage>((ref) {
  throw UnimplementedError();
});

final holdingStorageProvider =
Provider<HoldingLocalStorage>((ref) {
  throw UnimplementedError();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await createApp();

  runApp(app);
}

Future<Widget> createApp() async {
  await Hive.initFlutter();

  final watchlistStorage = WatchlistLocalStorage();
  await watchlistStorage.init();

  final walletStorage = WalletLocalStorage();
  await walletStorage.init();

  final orderStorage = OrderLocalStorage();
  await orderStorage.init();

  final holdingStorage = HoldingLocalStorage();
  await holdingStorage.init();

  return ProviderScope(
    overrides: [
      watchlistStorageProvider.overrideWithValue(
        watchlistStorage,
      ),
      walletStorageProvider.overrideWithValue(
        walletStorage,
      ),
      orderStorageProvider.overrideWithValue(
        orderStorage,
      ),
      holdingStorageProvider.overrideWithValue(
        holdingStorage,
      ),
    ],
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '021 Trading App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final screens = const [
    MarketScreen(),
    WatchlistScreen(),
    HoldingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
            ),
            label: 'Holdings',
          ),
        ],
      ),
    );
  }
}

Future<Widget> createAppForTest() async {
  final watchlistStorage = WatchlistLocalStorage();
  await watchlistStorage.init();

  final walletStorage = WalletLocalStorage();
  await walletStorage.init();

  final orderStorage = OrderLocalStorage();
  await orderStorage.init();

  final holdingStorage = HoldingLocalStorage();
  await holdingStorage.init();

  return ProviderScope(
    overrides: [
      watchlistStorageProvider.overrideWithValue(
        watchlistStorage,
      ),
      walletStorageProvider.overrideWithValue(
        walletStorage,
      ),
      orderStorageProvider.overrideWithValue(
        orderStorage,
      ),
      holdingStorageProvider.overrideWithValue(
        holdingStorage,
      ),
    ],
    child: const MyApp(),
  );
}