//Card layout with imported class for OpenOrder objects.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../data.dart'; //used for meta and links classes
import '../auth.dart';
import 'package:intl/intl.dart'; //for number formatting

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String title = 'History';

  //Open Order Variables
  List<Map<String, dynamic>> openOrderList = [];
  int _pageOO = 1;
  var _prevOO = null;
  var _nextOO = null;
  var _pageMessageOO = "";

  //Purchase History Variables
  List<Map<String, dynamic>> phList = [];
  int _pagePH = 1;
  var _prevPH = null;
  var _nextPH = null;
  var _pageMessagePH = "";

  //Get the open orders from the API
  Future<List<Map<String, dynamic>>?> _getOpenOrders() async {
    final token = await ProductstoreAuth().getToken();

    //print(token);

    http.Request request = http.Request(
        'GET',
        Uri.parse(
            ApiConstants.baseUrl + ApiConstants.ooEndpoint + '?page=$_pageOO'));

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

            //Parse the meta and links data
            Map<String, dynamic> jsonMap = jsonDecode(response.body);

            // Create the metaData object using the factory method
            //ApiMetaData metaData = ApiMetaData.fromJson(jsonMap);

            //Create the apiLinks object using the factory method
            ApiLinks apiLinks = ApiLinks.fromJson(jsonMap);

            //debugPrint(response.body);

            _prevOO = apiLinks.prev;
            _nextOO = apiLinks.next;
            //_page = metaData.current_page;

            _pageMessageOO = "Page $_pageOO";

            return parseDataOO(json);
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
  List<Map<String, dynamic>> parseDataOO(Map<String, dynamic> json) {
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

  //Get the purchase history from the API
  Future<List<Map<String, dynamic>>?> _getPurchaseHistory() async {
    final token = await ProductstoreAuth().getToken();

    //print(token);

    http.Request request = http.Request(
        'GET',
        Uri.parse(
            ApiConstants.baseUrl + ApiConstants.phEndpoint + '?page=$_pagePH'));

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

            //Parse the meta and links data
            Map<String, dynamic> jsonMap = jsonDecode(response.body);

            // Create the metaData object using the factory method
            //ApiMetaData metaData = ApiMetaData.fromJson(jsonMap);

            //Create the apiLinks object using the factory method
            ApiLinks apiLinks = ApiLinks.fromJson(jsonMap);

            //debugPrint(response.body);

            _prevPH = apiLinks.prev;
            _nextPH = apiLinks.next;
            //_page = metaData.current_page;

            _pageMessagePH = "Page $_pagePH";

            return parseDataPH(json);
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
  List<Map<String, dynamic>> parseDataPH(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> dataList = [];
    final pData = json['data'] as List;

    for (var order in pData) {
      final Map<String, dynamic> orderMap = {};
      orderMap['item_number'] = order['item_number'];
      orderMap['item_description'] = order['item_description'];
      orderMap['image_urls'] = order['image_urls'];
      orderMap['price'] = order['price'];
      dataList.add(orderMap);
    }

    return dataList;
  }

  Future<void> saveFrom() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('from', '/history');
  }

  @override
  void initState() {
    super.initState();

    //Populate the Purchase History tab
    _getPurchaseHistory().then((ResultsFromServer) {
      if (ResultsFromServer != null) {
        setState(() {
          phList = ResultsFromServer;
        });
      }
    });

    //Populate the Open Orders tab
    _getOpenOrders().then((ResultsFromServer) {
      if (ResultsFromServer != null) {
        setState(() {
          openOrderList = ResultsFromServer;
        });
      }
    });

    saveFrom();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2, // Adjust the number of tabs based on your needs
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    RouteStateScope.of(context).go('/cart');
                  }),
            ],
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
                Tab(text: 'Recent Items'),
                Tab(text: 'Open Orders'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Content for the recent items tab
              phList.isEmpty
                  ? Text("") //No recent items
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.all(5),
                            itemCount: phList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  // Handle the click event here
                                  //RouteStateScope.of(context).go('/product/0');
                                  RouteStateScope.of(context).go(
                                      '/apiproduct/${phList[index]['item_number']}');
                                  //or try /apiproduct/:item_number
                                  //print('Card ${productList[index].item_number} clicked!');
                                },
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 0), //card padding
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                            child: Image.network(
                                              phList[index]['image_urls'][0],
                                              //productList[index].image_urls, //was a string, now a list.
                                              //'https://images.bwicompanies.com/DA05TREES.jpg', //if hardcode
                                              //width: 80,
                                              height: 80,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 15, 20, 15),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    phList[index]
                                                        ['item_description'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    phList[index]
                                                        ['item_number'],
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    '\$${phList[index]['price']}',
                                                    //If price is returned as a double convert to string and format to 2 decimal places.
                                                    //'\$${productList[index].price.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.green),
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        //add a separator and pagination under cards
                        //Divider(),
                        PreferredSize(
                          preferredSize: Size.fromHeight(58),
                          child: Container(
                              height: 58.0,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5),
                              //color: Colors.green[600],
                              child: Row(
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back),
                                      color: Colors.grey[700],
                                      onPressed: _prevPH == null
                                          ? null
                                          : () {
                                              //can be pressed (Otherwise gray out)
                                              // now that we disable the button if _prev is null, we can update the page number and update the productList.
                                              if (_prevPH != null) {
                                                setState(() {
                                                  _pagePH = _pagePH - 1;
                                                });

                                                _getPurchaseHistory()
                                                    .then((ResultsFromServer) {
                                                  if (ResultsFromServer !=
                                                      null) {
                                                    setState(() {
                                                      phList =
                                                          ResultsFromServer;
                                                      //_totalResults = productList.length;
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                    ),
                                  ),
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    _pageMessagePH,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[700],
                                    ),
                                  ))),
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_forward),
                                      color: Colors.grey[700],
                                      onPressed: _nextPH == null
                                          ? null
                                          : () {
                                              // now that we disable the button if _next is null, we can update the page number and update the productList.
                                              if (_nextPH != null) {
                                                setState(() {
                                                  _pagePH = _pagePH + 1;
                                                });

                                                _getPurchaseHistory()
                                                    .then((ResultsFromServer) {
                                                  if (ResultsFromServer !=
                                                      null) {
                                                    setState(() {
                                                      phList =
                                                          ResultsFromServer;
                                                      //_totalResults = productList.length;
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
              // Content for the Open Orders tab
              openOrderList.isEmpty
                  ? Text("") //No Open Orders
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
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
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 15, 20, 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Order#: " +
                                                openOrderList[index]
                                                    ['order_number'],
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
                                                text: openOrderList[index][
                                                    'orderdate'], //or requesteddate?
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
                                                EdgeInsets.fromLTRB(
                                                    15, 0, 15, 20),
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
                                                  openOrderList[index]
                                                      ['shiptoname'],
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              Visibility(
                                                visible: openOrderList[index]
                                                        ['shiptoaddr1']
                                                    .isNotEmpty,
                                                child: Text(
                                                  openOrderList[index]
                                                      ['shiptoaddr1'],
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              Visibility(
                                                visible: openOrderList[index]
                                                        ['shiptoaddr2']
                                                    .isNotEmpty,
                                                child: Text(
                                                  openOrderList[index]
                                                      ['shiptoaddr2'],
                                                  style:
                                                      TextStyle(fontSize: 12),
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
                                                itemBuilder:
                                                    (context, lineIndex) {
                                                  final line =
                                                      openOrderList[index]
                                                          ['lines'][lineIndex];
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('Items Ordered:'),
                                                      SizedBox(height: 5),
                                                      Visibility(
                                                        visible:
                                                            line['item_number']
                                                                .isNotEmpty,
                                                        child: Text(
                                                          line['item_number'],
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: line[
                                                                'item_description']
                                                            .isNotEmpty,
                                                        child: Text(
                                                          line[
                                                              'item_description'],
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            line['uom_desc']
                                                                .isNotEmpty,
                                                        child: Text(
                                                          line['quantity'] +
                                                              ' ' +
                                                              line['uom_desc'] +
                                                              ' - \$' +
                                                              line['unitprice'],
                                                          style: TextStyle(
                                                              fontSize: 12),
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
                        ),
                        //add a separator and pagination under cards
                        //Divider(),
                        PreferredSize(
                          preferredSize: Size.fromHeight(58),
                          child: Container(
                              height: 58.0,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5),
                              //color: Colors.green[600],
                              child: Row(
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back),
                                      color: Colors.grey[700],
                                      onPressed: _prevOO == null
                                          ? null
                                          : () {
                                              //can be pressed (Otherwise gray out)
                                              // now that we disable the button if _prev is null, we can update the page number and update the productList.
                                              if (_prevOO != null) {
                                                setState(() {
                                                  _pageOO = _pageOO - 1;
                                                });

                                                _getOpenOrders()
                                                    .then((ResultsFromServer) {
                                                  if (ResultsFromServer !=
                                                      null) {
                                                    setState(() {
                                                      openOrderList =
                                                          ResultsFromServer;
                                                      //_totalResults = productList.length;
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                    ),
                                  ),
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    _pageMessageOO,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[700],
                                    ),
                                  ))),
                                  Expanded(
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_forward),
                                      color: Colors.grey[700],
                                      onPressed: _nextOO == null
                                          ? null
                                          : () {
                                              // now that we disable the button if _next is null, we can update the page number and update the productList.
                                              if (_nextOO != null) {
                                                setState(() {
                                                  _pageOO = _pageOO + 1;
                                                });

                                                _getOpenOrders()
                                                    .then((ResultsFromServer) {
                                                  if (ResultsFromServer !=
                                                      null) {
                                                    setState(() {
                                                      openOrderList =
                                                          ResultsFromServer;
                                                      //_totalResults = productList.length;
                                                    });
                                                  }
                                                });
                                              }
                                            },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
            ], //tab bar view children
          ), //tabbarview
        ), //body scaffold
      ); //build widget
} //history screen state class
