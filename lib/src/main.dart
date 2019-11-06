import 'package:bird_flutter/bird_flutter.dart';

import 'package:flutter/material.dart';
import 'package:modulovalue_project_widgets/all.dart';
import 'package:web3js_test_page/src/web3bloc.dart';

ListApplicator fadedCenter = listApply((children) {
  return center() > onWrap(spacing: 4.0) >> children;
});

Widget web3test() {
  final choreography = ChoreographyDelayTracker();

  return scaffold() > $$ >> (context) {
    final bloc = $$$(() => Web3Bloc());

    return center() > onListView(shrinkWrap: true) >> [

      ...villainFadeIn().delay(choreography.getPreMS(100)) * modulovalueTitle(
        "Flutter Web Ethereum web3.js Test Page",
        "web3js_test_page",
      ),

      verticalSpace(36.0),

      villainFadeIn().delay(choreography.getPreMS(100)) & center() > $$ >> (
          context) {
        final hasEthOrWeb3 = $(() => bloc.hasEthJSOrWeb3JS);

        return apply
        & textWeight900()
        & switcher(hasEthOrWeb3)
        & textColor(hasEthOrWeb3 ? Colors.green : Colors.red)
        & textAlignC()
            > Text(hasEthOrWeb3
                   ? "Your browser supports web3!"
                   :
                   "Your browser doesn't support web3. Please install MetaMask or a web3 capable browser.",
            );
      },

      verticalSpace(18.0),

      villainFadeIn().delay(choreography.getPreMS(100)) > fadedCenter >> [
        const Text("ethereum.js"),
        $widget(() => bloc.hasEthJS.map(checkMark)),
      ],

      verticalSpace(4.0),

      villainFadeIn().delay(choreography.getPreMS(100)) > fadedCenter >> [
        const Text("web3.js"),
        $widget(() => bloc.hasWeb3JS.map(checkMark)),
      ],

      verticalSpace(4.0),

      villainFadeIn().delay(choreography.getPreMS(100)) > fadedCenter >> [
        $widget(() {
          return bloc.networkName.map((network) {
            return switcher(network) > Text("Network: ${network | "?"}");
          });
        }),
      ],

      verticalSpace(4.0),

      villainFadeIn().delay(choreography.getPreMS(100)) > $widget(() {
        return bloc.address.map((account) {
          return switcher(account)
              > Text("Account: ${account.valueOrNull ?? "?"}");
        });
      }),

      verticalSpace(18.0),

      villainFadeIn().delay(choreography.getPreMS(100)) > $$ >> (context) {
        final hasEth = $(() => bloc.hasEthJS);
        return center() > RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0)),
          color: Colors.white,
          child: const Text("Request account access"),
          onPressed: hasEth ? bloc.requestAccountAccess : null,
        );
      },

      verticalSpace(8.0),

      villainFadeIn().delay(choreography.getPreMS(100)) > $$ >> (context) {
        final account = $(() => bloc.address);
        return center() > RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
          color: Colors.white,
          child: switcher(account) > Text("Get Balance for ${account | "..."}"),
          onPressed: account.fold(() => null, (address) =>
              () async {
            bloc.getBalanceFor(address, (balance) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Balance: ${balance.inEth} ETH"),
              ));
            });
          }),
        );
      }
    ];
  };
}

Widget checkMark(bool isChecked) {
  if (isChecked) {
    return switcher(isChecked) > Icon(
      Icons.check,
      size: 14,
      color: Colors.green,
    );
  } else {
    return switcher(isChecked) > Icon(
      Icons.remove,
      size: 14,
      color: Colors.red,
    );
  }
}

Applicator switcher(Object key) {
  return apply((child) {
    return AnimatedSwitcher(child: child, duration: ms100);
  }) & keyed(ValueKey(key));
}