import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_track/model.dart';
import 'package:stock_track/notif.dart';
import 'package:stock_track/settings.dart';
import 'package:stock_track/state.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  final pref = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [prefsProvider.overrideWith((ref) => pref)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timer.periodic(Duration(seconds: ref.read(settingsProvider).autoRefreshInSeconds), (timer) {
      ref.read(stockTrackerProvider.notifier).getStocks(ref.read(settingsProvider).stocks);
    });
    return MaterialApp(
      title: 'Stock track',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StockTrack(),
    );
  }
}

class StockTrack extends ConsumerWidget {
  const StockTrack({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(notifProvider, (prev, next) {
      if (next != null) {
        displayNotif(context, next);
        ref.read(notifProvider.notifier).displayNotif(null);
      }
    });
    return Scaffold(
        body: ref.watch(stockTrackerProvider).when(
            error: (e, stackTrace) => Center(child: Text(e.toString())),
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (stocks) {
              final colIdx = ref.read(sortProvider).colIndex;
              Comparable<dynamic> Function(Stock d) fct;
              if (colIdx == 0) {
                fct = (Stock d) => d.symbol;
              }
              if (colIdx == 1) {
                fct = (Stock d) => d.openValue;
              }
              if (colIdx == 2) {
                fct = (Stock d) => d.currentValue;
              }
              if (colIdx == 3) {
                fct = (Stock d) => d.prctSinceOpen;
              } else {
                fct = (Stock d) => d.prctSinceLast;
              }
              final stockDataSource = StockDataSource(stocks: stocks.values.toList());
              stockDataSource.filter(ref.read(filterProvider));
              stockDataSource.sort(fct, ref.read(sortProvider).ascending);
              return StockTable(stockDataSource);
            }));
  }
}

class StockDataSource extends DataTableSource {
  final List<Stock> stocks;
  late List<Stock> _stocks;
  String symbolFilter = "";
  StockDataSource({required this.stocks}) {
    _stocks = stocks;
  }

  Future<void> _launchUrl(String symbol) async {
    if (!await launchUrl(Uri.parse("https://www.etoro.com/markets/$symbol"))) {
      throw Exception('Could not launch "https://www.etoro.com/markets/$symbol"');
    }
  }

  Color getColor(num num) {
    if (num > 0) {
      return Colors.green;
    }
    if (num < 0) {
      return Colors.red;
    }
    return Colors.black;
  }

  @override
  DataRow? getRow(int index) {
    final stock = _stocks[index];
    return DataRow(cells: [
      DataCell(SelectableText(stock.symbol), onDoubleTap: () async=> _launchUrl(stock.symbol)),
      DataCell(SelectableText(stock.openValue.toString())),
      DataCell(SelectableText(stock.currentValue.toString())),
      DataCell(SelectableText("${stock.prctSinceOpen.toStringAsFixed(2)}%", style: TextStyle(color: getColor(stock.prctSinceOpen)))),
      DataCell(SelectableText("${stock.prctSinceLast.toStringAsFixed(2)}%", style: TextStyle(color: getColor(stock.prctSinceLast)))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _stocks.length;

  @override
  int get selectedRowCount => 0;

  void sort<T>(Comparable<T> Function(Stock d) getField, bool ascending) {
    _stocks.sort((Stock a, Stock b) {
      if (!ascending) {
        final Stock c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });

    notifyListeners();
  }

  void filter(String symbol) {
    if (symbol == symbolFilter) {
      return;
    }
    _stocks = stocks.where((element) => element.symbol.contains(symbol)).toList();
    symbolFilter = symbol;
    notifyListeners();
  }
}

class StockTable extends ConsumerStatefulWidget {
  const StockTable(this.data, {super.key});
  final StockDataSource data;
  @override
  ConsumerState<StockTable> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends ConsumerState<StockTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final _focusNode = FocusNode();
  final TextEditingController search = TextEditingController();
  void _sort<T>(Comparable<T> Function(Stock d) getField, int columnIndex, bool ascending) {
    widget.data.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    ref.read(sortProvider.notifier).update((state) => Sort(ascending: ascending, colIndex: columnIndex));
  }

  void _filter(String filter) {
    widget.data.filter(filter);
    _focusNode.unfocus();
    ref.read(filterProvider.notifier).update((state) => filter);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: search,
                  onEditingComplete: () => _filter(search.text),
                  onSubmitted: (value) => _filter(search.text),
                  onTapOutside: (event) => _filter(search.text),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder(), labelText: 'Search symbol', hintText: 'Rechercher un symbol'),
                ),
              ),
              IconButton(
                  onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>  SettingsView(onValidation: () => Navigator.of(context).pop()),
                      ),
                  icon: const Icon(Icons.settings))
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: FractionallySizedBox(
                widthFactor: 1,
                child: PaginatedDataTable(
                  sortAscending: _sortAscending,
                  sortColumnIndex: _sortColumnIndex,
                  rowsPerPage: 50,
                  columns: [
                    DataColumn(
                        label: const Text("Symbol"),
                        onSort: (columnIndex, ascending) => _sort<String>((Stock d) => d.symbol, columnIndex, ascending)),
                    DataColumn(
                        label: const Text("Open"),
                        onSort: (columnIndex, ascending) => _sort<num>((Stock d) => d.openValue, columnIndex, ascending)),
                    DataColumn(
                        label: const Text("Current"),
                        onSort: (columnIndex, ascending) => _sort<num>((Stock d) => d.currentValue, columnIndex, ascending)),
                    DataColumn(
                        label: const Text("Prct since open"),
                        onSort: (columnIndex, ascending) => _sort<num>((Stock d) => d.prctSinceOpen, columnIndex, ascending)),
                    DataColumn(
                        label: const Text("Prct since last fetch"),
                        onSort: (columnIndex, ascending) => _sort<num>((Stock d) => d.prctSinceLast, columnIndex, ascending)),
                  ],
                  source: widget.data,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
