import 'package:flutter/material.dart';
import 'package:web3js_test_page/src/main.dart';

void main() =>
    runApp(MaterialApp(
      title: 'Flutter Web Ethereum web3.js Test Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: web3test(),
    ));
