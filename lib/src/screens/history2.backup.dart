//Card layout with imported class for OpenOrder objects.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../data.dart';
import '../auth.dart';
import 'package:intl/intl.dart'; //for number formatting

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String title = 'History';
  List<OpenOrder> openOrderList = [];

  //Get the open orders from the API and return a list of OpenOrder objects to be saved as openOrderList
  Future<List<OpenOrder>?> _getOpenOrders() async {
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
            List<OpenOrder> list = parseData(response.body);

            return list;
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

  //Read Json string and return a list of OpenOrder objects. This is a static class function, no need to create instance
  static List<OpenOrder> parseData(String responseBody) {
    // Decode the JSON response into a Dart object.
    final decodedResponse = json.decode(responseBody);

    // Get the data array from the decoded object.
    final dataArray = decodedResponse['data'] as List<dynamic>;

    // Parse the data array into a list of objects and return
    final parsed = dataArray.cast<Map<String, dynamic>>();
    return parsed.map<OpenOrder>((json) => OpenOrder.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();

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
                        return GestureDetector(
                          onTap: () {
                            //If card is tapped, show a popup with these order details
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Order #' +
                                        openOrderList[index].order_number),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Shipping Information'),
                                        SizedBox(height: 5),
                                        //Show the line if it is not empty
                                        Visibility(
                                          visible: openOrderList[index]
                                              .shiptoname
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index].shiptoname,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Visibility(
                                          visible: openOrderList[index]
                                              .shiptoaddr1
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index].shiptoaddr1,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Visibility(
                                          visible: openOrderList[index]
                                              .shiptoaddr2
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index].shiptoaddr2,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Visibility(
                                          visible: openOrderList[index]
                                              .shiptocitystate
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index]
                                                .shiptocitystate,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Visibility(
                                          visible: openOrderList[index]
                                              .shiptozip5
                                              .isNotEmpty,
                                          child: Text(
                                            openOrderList[index].shiptozip5,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text('Items'),
                                        SizedBox(height: 5),

                                        //show line items. (Pic would be nice)
                                        /*
                                   
                                    "lines": [
                                      {
                                        "ordernum": "18588066",
                                        "item_number": "SXMOBUCKS",
                                        "item_description": "Mo' Bucks Feed - 40 lb",
                                        "uom": "BG",
                                        "uom_desc": "BAG",
                                        "quantity": "300",
                                        "unitprice": "10.57",
                                        "ups_enabled": "N",
                                        "pack_size": "Pk/1",
                                        "vendor": "BHM",
                                        "qtycancelled": "0",
                                        "qtymoved": "0"
                                      }
                                      */
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                });
                            /*
                            If we wanted to go to a detail page this is how you would do it
                            RouteStateScope.of(context).go(
                                //'/order/${openOrderList[index].order_number}');
                                '/home');*/
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
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Order#: " +
                                            openOrderList[index].order_number,
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
                                                .orderdate, //or requesteddate?
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
                                            text:
                                                openOrderList[index].customerpo,
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
                                                .friendlyStatus,
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
                                    Text(
                                      "More Information",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    /*
                                    ElevatedButton(
                                        onPressed: () {
                                          RouteStateScope.of(context).go(
                                              '/order/${openOrderList[index].order_number}');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary, // Set the background color
                                          foregroundColor: Colors
                                              .white, // Set the text color (optional)
                                        ),
                                        child: const Text('More Details',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold))),*/
                                  ],
                                ),
                              )),
                        );
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
