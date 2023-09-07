// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../data/library.dart';
import '../routing.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _scanBarcode = 'Unknown';

  /// For Continuous scan. (Doesnt return value, just a future function that sets a variable without blocking the interface)
  Future<void> startBarcodeScanStream() async {
    //This method will return a persistent stream of barcode scans until the client drops the activity. Returns a stream of barcode strings that were recognized.
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> barcodeScan() async {
    String barcodeScanRes;

    //This method will return outcome of scan as string. (Pass in scan line color, cancel button text, show flash icon, and ScanMode [QR, BARCODE, DEFAULT]
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);

    //tmp removed try catch since its showing an error with PlatformException. Platform messages may fail, so we will need to use a try/catch PlatformException.
    /*
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
        print(barcodeScanRes);
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }
      if (!mounted) return;
      setState(() {
        _scanBarcode = barcodeScanRes;
      });
    }
    */

    print(barcodeScanRes);

    _scanBarcode = barcodeScanRes;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan'),
          backgroundColor: Colors.green[700],
        ),
        body: Container(
            alignment: Alignment.center,
            child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Scan result : $_scanBarcode\n',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                        onPressed: () => barcodeScan(),
                        child: const Text('Barcode Scan',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold))),
                  ),
                ])),
      );
}
