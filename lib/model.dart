import 'package:flutter/material.dart';

class Stock {
  final String symbol;
  final num openValue;
  final num currentValue;
  final num precedentValue;

  Stock({required this.symbol, required this.openValue, required this.currentValue, required this.precedentValue});

  num get prctSinceOpen =>  currentValue==0?0:100*(currentValue-openValue)/currentValue;

  num get prctSinceLast =>  currentValue==0?0:100*(currentValue-precedentValue)/currentValue;

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
class Sort{
  final int colIndex;
  final bool ascending;

  const Sort({required this.colIndex, required this.ascending});
}

class Settings extends ChangeNotifier{
  late int autoRefreshInSeconds;
  late String apiKey;
  late List<String> stocks;

  Settings({required this.autoRefreshInSeconds, required this.apiKey, required this.stocks}); 
}