//This is the Product Catalog screen (Products Screen in Example)
//Sets App Bar & Tab Bar
//Loads ProductList widget

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

  List<Subject> ulist = []; //list from server
  List<Subject> userLists = []; //filtered list after typing

  //Not sure if this is working yet
  final authState = ProductstoreAuth();

  Future<List<Subject>> getAllulistList() async {
    final token = await authState.getToken(); // Get the token stored on device
    var url = Uri.parse('https://api.bwicompanies.com/v1/items/search');
    http.Request request = http.Request('GET', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Authorization'] = "'Content-Type': 'application/json'";
    request.body =
        '{"query": "boots", "account": "EOTH076", "web_enabled": true}';

    //Print to debug console
    //print(token);

    try {
      // Make the request.
      //var response = await http.Client().send(request);
      //Need to add query, account, web_enabled to body
      //final response = await http.request('GET', url, headers: headers, body: body);

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      List<Subject> list = parseAgents(response.body);

      //Hardcode response
      /*
      List<Subject> list =
          parseAgents('[{"item_number": "asdf"},{"item_number": "qewr"}]');
      */

      return list;
    } catch (e) {
      throw Exception(e.toString());
    }

    //Hard code the list variable using the Subject class and return it
    /*
    List<Subject> list = parseAgents(
        '[{"item_number": "asdf"},{"item_number": "qewr"}]'); //pass json and return a list of Subject objects.
    return list;
    */

/* throws error
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        print(response.body);
        List<Subject> list = parseAgents(response.body);
        return list;
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  
  */
  }

  //Read Json string and return a list of Subject objects.
  static List<Subject> parseAgents(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Subject>((json) => Subject.fromJson(json)).toList();
  }

  @override
  //When widget is first created, call api and update the 2 list variables
  //Details: getAllulistList function returns a future object and uses the then method to add a callback to update the list variables.
  void initState() {
    super.initState();
    getAllulistList().then((subjectFromServer) {
      setState(() {
        ulist = subjectFromServer;
        userLists = ulist;
      });
    });
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
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
                    color: Colors.blue,
                  ),
                ),
                suffixIcon: InkWell(
                  child: Icon(Icons.search),
                ),
                contentPadding: EdgeInsets.all(15.0),
                hintText: 'Search ',
              ),
              onChanged: (string) {
                _debouncer.run(() {
                  setState(() {
                    userLists = ulist
                        .where(
                          (u) => (u.item_number.toLowerCase().contains(
                                string.toLowerCase(),
                              )),
                        )
                        .toList();
                  });
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.all(5),
              itemCount: userLists.length,
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
                            userLists[index].item_number,
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            userLists[index].item_number ?? "null",
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

  Subject({
    required this.item_number,
  });

  factory Subject.fromJson(Map<dynamic, dynamic> json) {
    return Subject(
      item_number: json['item_number'],
    );
  }
}
