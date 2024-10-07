//Card layout with imported class for OpenOrder objects.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
//import '../data.dart';
import '../auth.dart';
import 'package:intl/intl.dart'; //for number formatting

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String title = 'History';
  List<Map<String, dynamic>> openOrderList = [];

  //Get the open orders from the API and return a list of OpenOrder objects to be saved as openOrderList
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

        if (response != null) {
          //print(response.statusCode);

          //Parse response
          if (response.statusCode == 200) {
            final json = jsonDecode(response.body);

            //List<Map<String, dynamic>> list = parseData(json);
            //return list;

            return parseData(json);
          } else {
            return null;
          }
        } else {
          throw Exception('Error');
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Function to parse the Open Orders JSON and create the desired data structure
  List<Map<String, dynamic>> parseData(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> dataList = [];
    final orderData = json['data'] as List;

    for (var order in orderData) {
      final Map<String, dynamic> orderMap = {};
      orderMap['order_number'] = order['order_number'];
      orderMap['orderdate'] = order['orderdate'];
      orderMap['customerpo'] = order['customerpo'];
      orderMap['friendlyStatus'] = order['friendlyStatus'];
      orderMap['shiptoname'] = order['shiptoname'];
      orderMap['shiptoaddr1'] = order['shiptoaddr1'];
      orderMap['shiptoaddr2'] = order['shiptoaddr2'];
      orderMap['shiptocitystate'] = order['shiptocitystate'];
      orderMap['shiptozip5'] = order['shiptozip5'];

      // Extract item information from the "lines" list
      final lines = order['lines'] as List;
      final List<Map<String, dynamic>> itemList = [];
      for (var item in lines) {
        final Map<String, dynamic> itemMap = {};
        itemMap['ordernum'] = item['ordernum'];
        itemMap['item_number'] = item['item_number'];
        itemMap['item_description'] = item['item_description'];
        itemMap['uom'] = item['uom'];
        itemMap['uom_desc'] = item['uom_desc'];
        itemMap['quantity'] = item['quantity'];
        itemMap['unitprice'] = item['unitprice'];
        itemMap['ups_enabled'] = item['ups_enabled'];
        itemMap['pack_size'] = item['pack_size'];
        itemMap['vendor'] = item['vendor'];
        itemMap['qtycancelled'] = item['qtycancelled'];
        itemMap['qtymoved'] = item['qtymoved'];

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

    //Populate the Open Orders tab
    _getOpenOrders().then((ResultsFromServer) {
      if (ResultsFromServer != null) {
        setState(() {
          openOrderList = ResultsFromServer;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2, // Adjust the number of tabs based on your needs
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Theme.of(context).colorScheme.primary,
            titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
            ),
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor:
                  Colors.white70, // Lighter shade for unselected tabs
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 4.0),
                insets: EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, 2.0), // Adjust this to move the underline up
              ),
              //indicatorColor: Colors.green[900],
              tabs: [
                Tab(text: 'Open Orders'),
                Tab(text: 'Purchase History'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Content for the first tab
              openOrderList.isEmpty
                  ? Text("No Open Orders")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.all(5),
                      itemCount: openOrderList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Order#: " +
                                          openOrderList[index]['order_number'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  //Divider(),
                                  SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Order Date: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: openOrderList[index]
                                              ['orderdate'], //or requesteddate?
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'PO#: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: openOrderList[index]
                                              ['customerpo'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Status: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: openOrderList[index]
                                              ['friendlyStatus'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //More information box
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                    ),
                                    child: ExpansionTile(
                                      dense: true,
                                      childrenPadding:
                                          EdgeInsets.fromLTRB(15, 0, 15, 20),
                                      expandedCrossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      title: Text(
                                        "More Information",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      children: [
                                        Text('Ship To:'),
                                        Visibility(
                                          visible: openOrderList[index]
                                                  ['shiptoname']
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index]['shiptoname'],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Visibility(
                                          visible: openOrderList[index]
                                                  ['shiptoaddr1']
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index]['shiptoaddr1'],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Visibility(
                                          visible: openOrderList[index]
                                                  ['shiptoaddr2']
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index]['shiptoaddr2'],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Text(
                                          openOrderList[index]
                                                  ['shiptocitystate'] +
                                              ' ' +
                                              openOrderList[index]
                                                  ['shiptozip5'],
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(height: 15),
                                        ListView.builder(
                                          shrinkWrap:
                                              true, // Prevent nested list view from expanding
                                          physics:
                                              NeverScrollableScrollPhysics(), // Disable scrolling
                                          itemCount: openOrderList[index]
                                                  ['lines']
                                              .length,
                                          itemBuilder: (context, lineIndex) {
                                            final line = openOrderList[index]
                                                ['lines'][lineIndex];
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Items Ordered:'),
                                                SizedBox(height: 5),
                                                Visibility(
                                                  visible: line['item_number']
                                                      .isNotEmpty,
                                                  child: Text(
                                                    line['item_number'],
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      line['item_description']
                                                          .isNotEmpty,
                                                  child: Text(
                                                    line['item_description'],
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: line['uom_desc']
                                                      .isNotEmpty,
                                                  child: Text(
                                                    line['quantity'] +
                                                        ' ' +
                                                        line['uom_desc'] +
                                                        ' - \$' +
                                                        line['unitprice'],
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ));
                      },
                    ),

              // Content for the second tab
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Content of Tab 2'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
