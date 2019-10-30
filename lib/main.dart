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
      title: 'Flutter Web Ethereum web3.js Test Page',
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

extension OptionMapEntryBool on Option<bool> {
  bool get isActive => this | false;
}

extension OptionMapEntryString on Option<String> {
  bool get hasValue => this.map((a) => a != null) | false;

  String get valueOrNull => this | null;
}

class _TestState extends State<Test> {
  Option<bool> hasEthereum = none();
  Option<bool> hasWeb3 = none();
  Option<String> netID = none();
  Option<String> account = none();

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      /// check ethereum.js
      if (js.context.hasProperty("ethereum") != hasEthereum.isActive) {
        setState(() => hasEthereum = some(js.context.hasProperty("ethereum")));
      }

      /// check web3.js
      if (js.context.hasProperty("web3") != hasWeb3.isActive) {
        setState(() => hasWeb3 = some(js.context.hasProperty("web3")));
      }

      /// check network id
      try {
        (js.context["web3"]["version"] as js.JsObject)
            .callMethod("getNetwork", <dynamic>[
          (dynamic err, dynamic id) {
            if (!this.netID.hasValue ||
                this.netID.valueOrNull != id.toString()) {
              setState(() => this.netID = some(id.toString()));
            }
          },
        ]);
      } catch (e) {
        (js.context["web3"]["eth"]["net"] as js.JsObject).callMethod(
          "getNetworkType",
          <dynamic>[
            (dynamic netID) {
              if (!this.netID.hasValue ||
                  this.netID.valueOrNull != netID.toString()) {
                setState(() => this.netID = some(netID.toString()));
              }
            }
          ],
        );
      }

      /// get account
      final arr = js.context["web3"]["eth"]["accounts"] as js.JsArray;
      if (arr.isNotEmpty) {
        final dynamic _account = arr[0];
        if (!account.hasValue || _account.toString() != account.valueOrNull) {
          setState(() => account = some(_account.toString()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            ...modulovalueTitle("Flutter Web Ethereum web3.js Test Page", "web3js_test_page"),
            const SizedBox(height: 36.0),
            Center(
              child: Text(
                hasEthereum.isActive || hasWeb3.isActive
                    ? "Your browser supports web3"
                    : "Your browser doesn't support web3. \nPlease install MetaMask or a web3 capable browser.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8.0),
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
                    Text("Network: ${netID.map(network) | "?"}"),
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
            if (hasEthereum.isActive)
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
                        (dynamic err, dynamic wei) {
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
                        },
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
