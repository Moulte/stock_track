import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_track/api.dart';
import 'package:stock_track/model.dart';

class StockNotifier extends StateNotifier<AsyncValue<Map<String, Stock>>> {
  final Api api;
  final Ref ref;
  StockNotifier(this.api, this.ref) : super(const AsyncLoading());

  getStocks(List<String> stocksToWatch) async {
    List<Stock> stocks = [];
    try {
      stocks = await api.getRealTimeStockData(stocks: stocksToWatch);
    } catch (e) {
      ref.read(notifProvider.notifier).displayNotif("Can't get real time data. $e");
      return;
    }
    if (state is AsyncLoading) {
      List<String> errors;
      try {
        (stocks, errors) = await api.getOpenStockData(stocks);
        if(errors.isNotEmpty){
          ref.read(notifProvider.notifier).displayNotif("Can't get open price. $errors");
        }
      } catch (e) {
        ref.read(notifProvider.notifier).displayNotif("Can't get open price. $e");
        return;
      }
    }

    state = AsyncValue.data(state.maybeWhen(
      data: (data) {
        final newState = <String, Stock>{};
        for (var stock in stocks) {
          final old = data[stock.symbol] ?? stock;
          newState[stock.symbol] = stock.copyWith(precedentValue: old.currentValue, openValue: old.openValue);
        }
        return newState;
      },
      orElse: () {
        final newState = <String, Stock>{};
        for (var stock in stocks) {
          newState[stock.symbol] = stock;
        }
        return newState;
      },
    ));
  }
}

List<Stock> decodeStock(String encoded) {
  final decoded = jsonDecode(encoded);
  final stocks = <Stock>[];
  for (var data in decoded) {
    stocks.add(
      Stock(
        currentValue: data["askPrice"],
        precedentValue: data["askPrice"],
        openValue: data["askPrice"],
        symbol: data["symbol"],
      ),
    );
  }
  return stocks;
}

final apiProvider = Provider((ref) {
  final settings = ref.watch(settingsProvider);
  // if (kDebugMode) {
  //   return MockApi();
  // }
  return Api(apiKey: settings.apiKey);
});

final stockTrackerProvider = StateNotifierProvider<StockNotifier, AsyncValue<Map<String, Stock>>>((ref) {
  final stockNotifier = StockNotifier(ref.watch(apiProvider), ref);
  final settings = ref.watch(settingsProvider);
  stockNotifier.getStocks(settings.stocks);
  return stockNotifier;
});

final sortProvider = StateProvider<Sort>((ref) => const Sort(ascending: true, colIndex: 0));
final filterProvider = StateProvider<String>((ref) => "");

final prefsProvider = Provider<SharedPreferences>((ref) {
  throw "Can't initialise sharedpreferences";
});

final settingsProvider = ChangeNotifierProvider<Settings>((ref) {
  final prefs = ref.watch(prefsProvider);
  return Settings(
    autoRefreshInSeconds: prefs.getInt("autoRefreshInSeconds") ?? 60,
    apiKey: prefs.getString("apiKey") ?? "",
    stocks: prefs.getStringList("stocks") ?? [],
  );
});

final notifProvider = StateNotifierProvider<Notif, String?>((ref) {
  return Notif(null);
});

class Notif extends StateNotifier<String?> {
  Notif(super.state);
  void displayNotif(String? notifText) {
    state = notifText;
  }
}
