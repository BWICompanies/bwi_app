//This is the Product Catalog screen
//Sets App Bar & Tab Bar. (Right now not using tabs.)
//Loads ProductList widget (Right now not using and reading api)

import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../auth.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/product_search_delegate.dart';

import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:http/http.dart' as http; //for api requests

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _debouncer = Debouncer();

  List<Subject> productList = []; //products returned from API

  final authState = ProductstoreAuth();

  Future<List<Subject>?> getProducts(String searchString) async {
    final token = await authState.getToken(); // Get the token stored on device
    var url = Uri.parse(
        "https://api.bwicompanies.com/v1/items/search?q=$searchString&account=EOTH076&web_enabled=true");
    http.Request request = http.Request('GET', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';

    try {
      // Update to indicate that the streamedResponse and response variables can be null.
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        // Add a null check to the if statement before parsing the response.
        if (response != null) {
          //Parse response
          if (response.statusCode == 200) {
            List<Subject> list = parseAgents(response.body);
            return list;
          } else {
            // Change the return type to indicate that the function may return a null value.
            return null;
          }
        } else {
          // Throw an exception if the response is null.
          throw Exception('Error');
        }
      } else {
        // Throw an exception if the streamedResponse is null.
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //Read Json string and return a list of Subject objects from data array.
  static List<Subject> parseAgents(String responseBody) {
    // Decode the JSON response into a Dart object.
    final decodedResponse = json.decode(responseBody);

    // Get the data array from the decoded object.
    final dataArray = decodedResponse['data'] as List<dynamic>;

    // Parse the data array into a list of Subject objects and return
    final parsed = dataArray.cast<Map<String, dynamic>>();
    return parsed.map<Subject>((json) => Subject.fromJson(json)).toList();
  }

  @override
  //When widget is first created, call api and update the 2 list variables
  //Details: getProducts function returns a future object and uses the then method to add a callback to update the list variables.
  void initState() {
    super.initState();
    getProducts("Hoods").then((subjectFromServer) {
      if (subjectFromServer != null) {
        setState(() {
          // Set the productList variable to the subjectFromServer variable.
          productList = subjectFromServer;
        });
      }
    });
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    /*
    final TextEditingController _textEditingController =
        TextEditingController();
    */

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                RouteStateScope.of(context).go('/cart');
              }),
        ], //for i
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: <Widget>[
          //Search Bar to List of typed Subject
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              //controller: _textEditingController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.green,
                  ),
                ),
                suffixIcon: InkWell(
                  child: Icon(Icons.search),
                ),
                contentPadding: EdgeInsets.all(15.0),
                hintText: 'Search ',
              ),
              onChanged: (value) {
                //print(value);

                //run api on change and update products

                if (value != "") {
                  getProducts(value).then((subjectFromServer) {
                    if (subjectFromServer != null) {
                      setState(() {
                        // Set the productList variable to the subjectFromServer variable.
                        productList = subjectFromServer;
                      });
                    }
                  });
                }

                /*
                _debouncer.run(() {
                  setState(() {
                    //update the userLists variable with the results of a new api call
                    userLists.toList();
                  });
                });
                */
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.all(5),
              itemCount: productList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            productList[index].item_description,
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            productList[index].item_number ?? "null",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//Declare Subject class for json data
class Subject {
  var item_number;
  var item_description;
  /*
  var longdesc;
  var pack_size;
  var stocking_unit_of_measure;
  var stocking_uom_desc;
  var sales_unit_of_measure;
  var sales_uom_desc;
  var primary_vendor;
  var vendor_name;
  var market_type;
  var division;
  //var class;
  var mandatory_drop_ship;
  var ups_eligible;
  var item_status;
  var web_enabled;
  var nosell;
  var stock_nonstock_item;
  var upc;
  var market_price;
  var add_timestamp;
  var update_timestamp;
  var image_urls;
  var is_new;
  var price;
  var uomData;
  var qtyBreaks;
  */

  Subject({
    required this.item_number,
    required this.item_description,
  });

  factory Subject.fromJson(Map<dynamic, dynamic> json) {
    return Subject(
      item_number: json['item_number'],
      item_description: json['item_description'],
    );
  }
}
