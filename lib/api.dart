// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stock_track/model.dart';
import 'package:http/http.dart' as http;
import 'package:stock_track/utils.dart';

class MockApi implements Api {
  @override
  String get apiKey => "";

  @override
  Future<(List<Stock>, List<String>)> getOpenStockData(List<Stock> stocks) async {
    final _stocks = [
      Stock(
        symbol: "TEST",
        openValue: 0.5,
        currentValue: 1,
        precedentValue: 1,
      ),
      Stock(
        symbol: "FAKEAAPL",
        openValue: 190,
        currentValue: 200,
        precedentValue: 150,
      ),
      Stock(
        symbol: "FAKENVDA",
        openValue: 900,
        currentValue: 1200,
        precedentValue: 1000,
      ),
      Stock(
        symbol: "TESLA",
        openValue: 200,
        currentValue: 150,
        precedentValue: 140,
      ),
    ];
    if (stocks.isNotEmpty) {
      return (_stocks.where((element) => stocks.map((e) => e.symbol).contains(element.symbol)).toList(),<String>[]);
    }
    return (_stocks,<String>[]);
  }

  @override
  Future<List<Stock>> getRealTimeStockData({List<String>? stocks}) async {
    final _stocks = [
      Stock(
        symbol: "TEST",
        openValue: 0,
        currentValue: 0.3,
        precedentValue: 1,
      ),
      Stock(
        symbol: "FAKEAAPL",
        openValue: 0,
        currentValue: 200,
        precedentValue: 150,
      ),
      Stock(
        symbol: "FAKENVDA",
        openValue: 0,
        currentValue: 1200,
        precedentValue: 1000,
      ),
      Stock(
        symbol: "TESLA",
        openValue: 0,
        currentValue: 150,
        precedentValue: 140,
      ),
    ];
    if (stocks != null && stocks.isNotEmpty) {
      return _stocks.where((element) => stocks.contains(element.symbol)).toList();
    }
    return _stocks;
  }
}

class Api {
  final String apiKey;

  Api({required this.apiKey});

  Future<List<Stock>> getRealTimeStockData({List<String>? stocks}) async {
    final responseRealTime =
        await http.get(Uri.parse("https://financialmodelingprep.com/api/v3/stock/full/real-time-price?apikey=$apiKey"));

    if (responseRealTime.statusCode > 299) {
      throw responseRealTime.body;
    }

    final _stocks = await compute<String, List<Stock>>(decodeStock, responseRealTime.body);
    if (stocks != null && stocks.isNotEmpty) {
      return _stocks.where((element) => stocks.contains(element.symbol)).toList();
    }
    return _stocks;
  }

  Future<(List<Stock>, List<String>)> getOpenStockData(List<Stock> stocks) async {
    final stockLists = splitList(stocks, 20);
    List<Future<http.Response>> futures = [];
    for (var stock in stockLists) {
      final stockStr = stock.map((e) => e.symbol).join(",");
      futures.add(http.get(Uri.parse("https://financialmodelingprep.com/api/v3/quote/$stockStr?apikey=$apiKey")));
    }
    final responses = await Future.wait(futures);
    final errors = <String>[];
    for (var response in responses) {
      if (response.statusCode > 299) {
        errors.add(response.body);
        continue;
      }
      final datas = jsonDecode(response.body);
      for (var data in datas) {
        final idx = stocks.indexWhere((element) => element.symbol == data["symbol"]);
        if (idx != -1) {
          stocks[idx] = stocks[idx].copyWith(openValue: data["open"]);
        }
      }
    }
    return (stocks,errors);
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
