import 'package:flutter/material.dart';

class Stock {
  final String symbol;
  final num openValue;
  final num currentValue;
  final num precedentValue;

  Stock({required this.symbol, required this.openValue, required this.currentValue, required this.precedentValue});

  num get prctSinceOpen => currentValue == 0 ? 0 : 100 * (currentValue - openValue) / currentValue;

  num get prctSinceLast => currentValue == 0 ? 0 : 100 * (currentValue - precedentValue) / currentValue;

  Stock copyWith({String? symbol, num? openValue, num? currentValue, num? precedentValue}) {
    return Stock(
      symbol: symbol ?? this.symbol,
      openValue: openValue ?? this.openValue,
      currentValue: currentValue ?? this.currentValue,
      precedentValue: precedentValue ?? this.precedentValue,
    );
  }
}

@immutable
class Sort {
  final int colIndex;
  final bool ascending;

  const Sort({required this.colIndex, required this.ascending});
}

class Settings extends ChangeNotifier {
  late int _autoRefreshInSeconds;
  late String _apiKey;
  late List<String> _stocks;

  int get autoRefreshInSeconds => _autoRefreshInSeconds;
  String get apiKey => _apiKey;
  List<String> get stocks => _stocks;

  set autoRefreshInSeconds(int val) {
    _autoRefreshInSeconds = val;
    notifyListeners();
  }

  set apiKey(String val) {
    _apiKey = val;
    notifyListeners();
  }

  set stocks(List<String> val) {
    _stocks = val;
    notifyListeners();
  }

  Settings({required int autoRefreshInSeconds, required String apiKey, required List<String> stocks}) {
    _stocks = stocks;
    _autoRefreshInSeconds = autoRefreshInSeconds;
    _apiKey = apiKey;
  }
}
