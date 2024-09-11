// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http; //for api requests
import '../auth.dart';
import 'dart:convert'; //to and from json
import '../routing.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  //String _scanBarcode = '';
  String _message = 'Loading...';

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
    //My test product 20oz Mammoth Rover drinking cup returns 0856924006396 from the scan which matches the upc code on the product. (Which has no leading 0) DAMAMMS20ROVBLK

    //print(barcodeScanRes);

    //remove leading 0 from barcodeScanRes. The cup above returns 0856924006396 but the label doesnt have the 0.
    if (barcodeScanRes[0] == '0') {
      barcodeScanRes = barcodeScanRes.substring(1);
    }

    //Turn the UPC into a product number
    final token = await ProductstoreAuth().getToken();

    //print(token);

    http.Request request = http.Request(
        'GET',
        Uri.parse(
            ApiConstants.baseUrl + ApiConstants.upcEndpoint + barcodeScanRes));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';

    try {
      // Update to indicate that the streamedResponse and response variables can be null.
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        print(response.statusCode);
        print(ApiConstants.baseUrl + ApiConstants.upcEndpoint + barcodeScanRes);

        // Add a null check to the if statement before parsing the response.
        if (response != null) {
          //Turn the json response into an object
          if (response.statusCode == 200) {
            //turn json into map (associative array in PHP)
            //Map<String, dynamic> jsonMap = json.decode(response.body);

            // Decode the JSON response into a Dart object.
            final decodedResponse = json.decode(response.body);

            // Get the data array from the decoded object.
            final dataArray = decodedResponse['data'] as Map<String, dynamic>;
            final upc = dataArray['bwi_item_number'] as String;

            setState(() {
              _message = '';
            });

            //Do redirect to the product page
            RouteStateScope.of(context).go('/apiproduct/${upc}');

            //print(response.body);
            //print(jsonProduct.item_description);

            //return null;
          } else {
            setState(() {
              _message = 'UPC not found.\n$barcodeScanRes';
            });
            // Change the return type to indicate that the function may return a null value.
            //return null;
          }
        } else {
          // Throw an exception if the response is null.
          setState(() {
            _message = 'UPC not found.\n$barcodeScanRes';
          });
          throw Exception('Error');
        }
      } else {
        // Throw an exception if the streamedResponse is null.
        setState(() {
          _message = 'UPC not found.\n$barcodeScanRes';
        });
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }

    //end

    //take the user to the cart page as a test (Worked)
    //RouteStateScope.of(context).go('/cart');

    //now that we have the barcodeScanRes value, look up the product in the database to get its id number. Pass that to /apiproduct/${productList[index].item_number}
    //RouteStateScope.of(context).go('/apiproduct/DSWCF336C');

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
  }

  @override
  void initState() {
    super.initState();

    //print('ini ran');

    barcodeScan();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
          ),
        ),
        body: Container(
            alignment: Alignment.center,
            child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Text('Loading...', style: const TextStyle(fontSize: 20)),
                  Text(_message,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  /* SizedBox(
                    height: 45,
                    child: ElevatedButton(
                        onPressed: () => barcodeScan(),
                        child: const Text('Barcode Scan',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold))),
                  ),*/
                ])),
      );
}
