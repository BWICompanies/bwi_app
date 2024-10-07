//Example of using an ExpansionTile to display a list of orders with line items. Line Items are pulled from the api
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; //optional but helps with debugging
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../auth.dart';
import 'package:intl/intl.dart'; //for number formatting

class HistoryScreen extends StatefulWidget {
  //final String jsonData;

  const HistoryScreen();

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  //List openOrderList = [];

  List<Map<String, dynamic>> openOrderList = [];

  //Get the open orders from the API and return a list of objects
  Future<List<Map<String, dynamic>>?> _getOpenOrders() async {
    final token = await ProductstoreAuth().getToken();

    //print(token);

    http.Request request = http.Request(
        'GET', Uri.parse(ApiConstants.baseUrl + ApiConstants.ooEndpoint));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        //Parse response
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          return parseData(json);
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Function to parse the JSON and create the desired data structure
  List<Map<String, dynamic>> parseData(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> dataList = [];
    final orderData = json['data'] as List;

    for (var order in orderData) {
      final Map<String, dynamic> orderMap = {};
      orderMap['order_number'] = order['order_number'];
      // ... Add other relevant fields from the order object

      // Extract item information from the "lines" list
      final lines = order['lines'] as List;
      final List<Map<String, dynamic>> itemList = [];
      for (var item in lines) {
        final Map<String, dynamic> itemMap = {};
        itemMap['item_number'] = item['item_number'];

        // ... Add other relevant fields from the item object
        itemList.add(itemMap);
      }

      orderMap['lines'] = itemList; // Add the list of items to the order map
      dataList.add(orderMap);
    }

    return dataList;
  }

  @override
  void initState() {
    super.initState();

    _getOpenOrders().then((ResultsFromServer) {
      //Correctly contains both order and line data
      //print(ResultsFromServer);

      //[{order_number: 18717974, lines: [{item_number: TSPFS17}]}, {order_number: 18690542, lines: [{item_number: NL302040}]}, {order_number: 18682753, lines: [{item_number: FH24163}]}, {order_number: 18669265, lines: [{item_number: PC352873}]}, {order_number: 18642345, lines: [{item_number: SXDEER}]}, {order_number: 18468450, lines: [{item_number: FS199}]}, {order_number: 18432920, lines: [{item_number: CHTALG}]}, {order_number: 18370527, lines: [{item_number: PC27991BK07}]}, {order_number: 18242164, lines: [{item_number: BVF13004}]}]

      if (ResultsFromServer != null) {
        setState(() {
          openOrderList = ResultsFromServer;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: ListView.builder(
        itemCount: openOrderList.length,
        itemBuilder: (context, index) {
          //final order = openOrderList[index];
          //final orderNumber = order['order_number'];
          //final lines = order['lines'] as List<dynamic>;

          return ExpansionTile(
            title: Text(
              "Order Number: " + openOrderList[index]['order_number'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true, // Prevent nested list view from expanding
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: openOrderList[index]['lines'].length,
                itemBuilder: (context, lineIndex) {
                  final line = openOrderList[index]['lines'][lineIndex];
                  //final itemName = line['item_description'];
                  //final quantity = line['quantity'];
                  //final unitPrice = line['unitprice'];

                  return Text(
                    "- " +
                        line['item_number'] +
                        " itemName (xquantity) - \$(unitPrice)",
                    style: TextStyle(fontSize: 14),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
