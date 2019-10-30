import 'dart:async';
import 'dart:js' as js;

import 'package:dartz/dartz.dart' hide State;
import 'package:decimal/decimal.dart';

import 'package:flutter/material.dart';
import 'package:modulovalue_project_widgets/all.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3.js Test Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Test(),
    );
  }
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

extension OptionMapEntryBool on Option<MapEntry<DateTime, bool>> {
  bool get isActive => this.map((a) => a.value) | false;
}

extension OptionMapEntryString on Option<MapEntry<DateTime, String>> {
  bool get hasValue => this.map((a) => a.value != null) | false;

  String get valueOrNull => this.map((a) => a.value) | null;
}

class _TestState extends State<Test> {
  Option<MapEntry<DateTime, bool>> hasEthereum = none();
  Option<MapEntry<DateTime, bool>> hasWeb3 = none();
  Option<MapEntry<DateTime, String>> netID = none();
  Option<MapEntry<DateTime, String>> account = none();

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (timer) {
//      /// check ethereum.js
//      if (js.context.hasProperty("ethereum") != hasEthereum.isActive) {
//        setState(() => hasEthereum =
//            some(MapEntry(DateTime.now(), js.context.hasProperty("ethereum"))));
//      }
//
//      /// check web3.js
//      if (js.context.hasProperty("web3") != hasWeb3.isActive) {
//        setState(() => hasWeb3 =
//            some(MapEntry(DateTime.now(), js.context.hasProperty("web3"))));
//      }

      /// check network id
//      try {
        js.context["web3"]["version"].callMethod("getNetwork", <dynamic>[
          js.allowInterop((dynamic err, dynamic netID) {
            if (!this.netID.hasValue ||
                this.netID.valueOrNull != netID.toString()) {
              setState(() => this.netID =
                  some(MapEntry(DateTime.now(), netID.toString())));
            }
          }),
        ]);
//      } catch (e) {
//        js.context["web3"]["eth"]["net"].callMethod("getNetworkType", <dynamic>[
//          js.allowInterop((dynamic netID) {
//            if (!this.netID.hasValue ||
//                this.netID.valueOrNull != netID.toString()) {
//              setState(() => this.netID =
//                  some(MapEntry(DateTime.now(), netID.toString())));
//            }
//          }),
//        ]);
//      }
//
//      /// get account
//      final arr = js.context["web3"]["eth"]["accounts"] as js.JsArray;
//      if (arr.isNotEmpty) {
//        final dynamic _account = arr[0];
//        if (!account.hasValue || _account.toString() != account.valueOrNull) {
//          setState(() =>
//              account = some(MapEntry(DateTime.now(), _account.toString())));
//        }
//      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            ...modulovalueTitle("Web3.js Test Page", "web3js_test_page"),
            const SizedBox(height: 36.0),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Wrap(
                  spacing: 4.0,
                  children: <Widget>[
                    const Text("ethereum.js"),
                    Icon(hasEthereum.isActive ? Icons.check : Icons.remove,
                        size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Wrap(
                  spacing: 4.0,
                  children: <Widget>[
                    const Text("web3.js"),
                    Icon(hasEthereum.isActive ? Icons.check : Icons.remove,
                        size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Wrap(
                  spacing: 4.0,
                  children: <Widget>[
                    Text(
                        "Network: ${netID.map((a) => a.value).map(network) | "?"}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Wrap(
                  spacing: 4.0,
                  children: <Widget>[
                    Text("Account: ${account.valueOrNull ?? "?"}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18.0),
//            if (hasEthereum.isActive)
              Center(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0)),
                  color: Colors.white,
                  child: const Text("Request account access"),
                  onPressed: () async {
                    (js.context["ethereum"] as js.JsObject)
                        .callMethod("enable", <dynamic>[]);
                  },
                ),
              ),
            if (this.account.hasValue)
              Builder(builder: (context) {
                return Center(
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0)),
                    color: Colors.white,
                    child: Text("Get Balance for ${this.account.valueOrNull}"),
                    onPressed: () async {
                      (js.context["web3"]["eth"] as js.JsObject)
                          .callMethod("getBalance", <dynamic>[
                        this.account.valueOrNull,
                        'latest',
                        js.allowInterop((dynamic err, dynamic wei) {
                          final balance =
                              optionOf(Decimal.tryParse(wei.toString()))
                                      .map((a) {
                                    return (a / Decimal.fromInt(10).pow(18))
                                            .toString() +
                                        " ETH";
                                  }) |
                                  "Unknown";
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("Balance: $balance"),
                          ));
                        }),
                      ]);
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

String network(String id) {
  switch (id) {
    case "main":
      return 'Mainnet';
    case "1":
      return 'Mainnet';
    case "morden":
      return 'Test: Morden';
    case "2":
      return 'Test: Morden';
    case "ropsten":
      return 'Test: Ropsten';
    case "3":
      return 'Test: Ropsten';
    case "4":
      return 'Test: Rinkeby';
    case "42":
      return 'Test: Kovan';
    case "private":
      return 'Unknown network';
    default:
      return 'Unknown network';
  }
}
