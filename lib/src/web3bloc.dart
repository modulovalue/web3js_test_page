import 'dart:async';
import 'dart:js' as js;
import 'package:bird/base.dart';
import 'package:bird/bird.dart';
import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/web3dart.dart';

extension OptionMapEntryString on Option<String> {
  bool get hasValue => this.map((a) => a != null) | false;

  String get valueOrNull => this | null;
}

// ignore_for_file: close_sinks
class Web3Bloc extends HookBloc {
  final Signal<Option<bool>> _hasEthJS = HookBloc.disposeSink(Signal(none()));
  final Signal<Option<bool>> _hasWeb3JS = HookBloc.disposeSink(Signal(none()));
  final Signal<Option<String>> _netID = HookBloc.disposeSink(Signal(none()));
  final Signal<Option<String>> _account = HookBloc.disposeSink(Signal(none()));

  Wave<bool> hasEthJS;
  Wave<bool> hasWeb3JS;
  Wave<bool> hasEthJSOrWeb3JS;
  Wave<Option<String>> networkName;
  Wave<Option<String>> address;

  Web3Bloc() {
    final timer = Timer.periodic(
        const Duration(milliseconds: 100), _updateBlocTimer);
    disposeLater(() => timer.cancel());

    hasEthJS = _hasEthJS.wave.map((a) => a | false).distinct();
    hasWeb3JS = _hasWeb3JS.wave.map((a) => a | false).distinct();
    hasEthJSOrWeb3JS = hasEthJS.and(hasWeb3JS).latest((eth, web) => eth || web);
    networkName = _netID.wave.map((a) => a.map(network)).distinct();
    address = _account.wave.distinct();
  }

  void _updateBlocTimer(Timer timer) {
    /// check ethereum.js
    if (js.context.hasProperty("ethereum") != _hasEthJS.value | false) {
      _hasEthJS.add(some(js.context.hasProperty("ethereum")));
    }

    /// check web3.js
    if (js.context.hasProperty("web3") != _hasWeb3JS.value | false) {
      _hasWeb3JS.add(some(js.context.hasProperty("web3")));
    }

    /// check network id
    try {
      (js.context["web3"]["version"] as js.JsObject)
          .callMethod("getNetwork", <dynamic>[
            (dynamic err, dynamic id) {
          if (!this._netID.value.hasValue ||
              this._netID.value.valueOrNull != id.toString()) {
            this._netID.add(some(id.toString()));
          }
        },
      ]);
    } catch (e) {
      (js.context["web3"]["eth"]["net"] as js.JsObject).callMethod(
        "getNetworkType",
        <dynamic>[
              (dynamic netID) {
            if (!this._netID.value.hasValue ||
                this._netID.value.valueOrNull != netID.toString()) {
              this._netID.add(some(netID.toString()));
            }
          }
        ],
      );
    }

    /// get account
    final arr = js.context["web3"]["eth"]["accounts"] as js.JsArray;
    if (arr.isNotEmpty) {
      final dynamic _account = arr[0];
      if (!this._account.value.hasValue || _account.toString() != this
          ._account.value.valueOrNull) {
        this._account.add(some(_account.toString()));
      }
    }
  }

  void requestAccountAccess() {
    // ignore: invariant_booleans
    if (_hasEthJS.value | false) {
      (js.context["ethereum"] as js.JsObject)
          .callMethod("enable", <dynamic>[]);
    }
  }

  void getBalanceFor(String address,
      void Function(EtherAmount balance) callback) {
    // ignore: invariant_booleans
    if (_hasWeb3JS.value | false) {
      (js.context["web3"]["eth"] as js.JsObject)
          .callMethod("getBalance", <dynamic>[
        address,
        'latest',
            (dynamic err, dynamic wei) {
          final _balance = optionOf(Decimal.tryParse(wei.toString()));
          _balance.forEach((balance) {
            final bigIntBalance = BigInt.tryParse(balance.toString());
            if (bigIntBalance != null) {
              callback(EtherAmount.inWei(bigIntBalance));
            }
          });
        },
      ]);
    }
  }

  static String network(String id) {
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
}

extension EtherAmountInETH on EtherAmount {
  Decimal get inEth {
    final decimalWei = Decimal.tryParse(getInWei?.toString());
    if (decimalWei == null) {
      return null;
    } else {
      return decimalWei / Decimal.fromInt(10).pow(18);
    }
  }
}
