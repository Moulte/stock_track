import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_track/state.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({this.onValidation, super.key});
  final void Function()? onValidation;

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  late final TextEditingController _apiKeyController = TextEditingController();
  late final TextEditingController _stockController = TextEditingController();
  late final TextEditingController _refreshController = TextEditingController();

  bool validable = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = ref.read(settingsProvider).apiKey;
    _stockController.text = ref.read(settingsProvider).stocks.join(",");
    _refreshController.text = ref.read(settingsProvider).autoRefreshInSeconds.toString();
  }

  bool isValidable() {
    return !(ref.read(settingsProvider).apiKey == _apiKeyController.text &&
        ref.read(settingsProvider).stocks == _stockController.text.split(",") &&
        ref.read(settingsProvider).autoRefreshInSeconds == int.parse(_refreshController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: TextField(
                  onChanged: (value) {
                    setState(() {
                      validable = isValidable();
                    });
                  },
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.key,
                    ),
                    label: Text("Financial modeling api key"),
                    // labelStyle: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                  // style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      validable = isValidable();
                    });
                  },
                  controller: _refreshController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.timelapse,
                    ),
                    label: Text("Refresh delay in seconds"),
                    // labelStyle: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                  // style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: TextField(
                  onChanged: (value) {
                    setState(() {
                      validable = isValidable();
                    });
                  },
                  controller: _stockController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),

                    prefixIcon: Icon(
                      Icons.show_chart,
                    ),
                    label: Text("Stocks to watch"),
                    // labelStyle: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                  // style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                    onPressed: !validable
                        ? null
                        : () {
                            ref.read(settingsProvider).apiKey = _apiKeyController.text;
                            ref.read(settingsProvider).stocks = _stockController.text.split(",");
                            ref.read(settingsProvider).autoRefreshInSeconds = int.parse(_refreshController.text);
                            ref.read(prefsProvider).setString("apiKey", _apiKeyController.text);
                            ref.read(prefsProvider).setStringList("stocks", _stockController.text.isEmpty?[]:_stockController.text.split(","));
                            ref.read(prefsProvider).setInt("autoRefreshInSeconds", int.parse(_refreshController.text));
                            if(widget.onValidation!=null){
                              widget.onValidation!();
                            }
                          },
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Valider")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
