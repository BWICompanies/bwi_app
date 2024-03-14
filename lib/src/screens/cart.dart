// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../auth.dart';
import '../routing.dart';
import '../data/cartproduct.dart';

import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:http/http.dart' as http; //for api requests

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartProduct> productList = []; //cart products returned from API
  var _subtotal = "";
  var _truckEligibleSales = "";
  //Map<String, dynamic> _vendorMinimums = {};
  //var _vendorMinimums = {};
  dynamic _vendorMinimums = null;

  //Return the products in the cart
  Future<List<CartProduct>?> getProducts(String? searchString) async {
    final token = await ProductstoreAuth().getToken();

    //print("getProducts running. _page is $_page");

    http.Request request = http.Request(
        'GET', Uri.parse(ApiConstants.baseUrl + ApiConstants.cartEndpoint));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      // Update to indicate that the streamedResponse and response variables can be null.
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        // Add a null check to the if statement before parsing the response.
        if (response != null) {
          //Parse response
          if (response.statusCode == 200) {
            //Parse Products in JSON data into an array
            List<CartProduct> list = parseData(response.body);

            //Get the subtotal and other data from the response that is outside of the data array

            // Parse the JSON string into a Map
            Map<String, dynamic> jsonMap = jsonDecode(response.body);

            _subtotal = jsonMap['subtotal'].toString();

            //For BWI Truck Minimum (BON51012 is a good example of a product that will count)
            _truckEligibleSales = jsonMap['truckEligibleSales'].toString();

            //If vendormin is a map set the variable as map. If a list, set as a list. Else set as null.
            if (jsonMap['vendorMinimums'] is Map<String, dynamic>) {
              _vendorMinimums =
                  jsonMap['vendorMinimums'] as Map<String, dynamic>;
            } else if (jsonMap['vendorMinimums'] is List<dynamic>) {
              _vendorMinimums = jsonMap['vendorMinimums'] as List<dynamic>;

              //Treat [] as null
              if (_vendorMinimums.length == 0) {
                _vendorMinimums = null;
              }
            } else {
              _vendorMinimums = null;
            }

            //print(_vendorMinimums);
            //when nothing it is set to [] as an empty list
            //when returns it is a map
            //{FW2: {vendor_name: WindRiver Windchimes, message_text: Minimum purchase of $250 or more., min_amount: 250.00, current_amount: 457, text_only: 0}}

            //_vendorMinimums = jsonMap['vendorMinimums'] ?? {};

            //For Vendor Minimums
            /*
            if (_vendorMinimums.isNotEmpty) {
              print('yes');
            } else {
              print('no');
            }

            //if (dataHolder != null) {

            if (jsonMap['vendorMinimums']) {
              //_vendorMinimums = jsonMap['vendorMinimums'];
              print('yes');
            } else {
              print('no');
            }

            if (isListType(initialData)) {
              dataHolder = []; // Or use a List-specific initialization
            } else if (isMapType(initialData)) {
              dataHolder = {}; // Or use a Map-specific initialization
            } else {
              // Handle invalid data type
            }

            */

            //DSWCT936GN is a good example of a product with a vendor minimum
            //"vendorMinimums": []

            //_Exception (Exception: type 'List<dynamic>' is not a subtype of type 'bool')

            //print(_vendorMinimums);
            //flutter: {FW2: {vendor_name: WindRiver Windchimes, message_text: Minimum purchase of $250 or more., min_amount: 250.00, current_amount: 457, text_only: 0}}
            //print(_vendorMinimums['FW2']['vendor_name']); //WindRiver Windchimes
            //print('it is:');
            //print(_vendorMinimums.length);

            //Vendor Minimums uses vendorMinimums current_amount and vendorMinimums min_amount

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

  //Read Json string and return a list of CartProduct objects.
  //Return type is a list of objects of the type CartProduct. This is a static class function, no need to create instance
  static List<CartProduct> parseData(String responseBody) {
    // Decode the JSON response into a Dart object.
    final decodedResponse = json.decode(responseBody);

    // Get the data array from the decoded object.
    final dataArray = decodedResponse['data'] as List<dynamic>;

    // Parse the data array into a list of ApiProduct objects and return
    final parsed = dataArray.cast<Map<String, dynamic>>();
    return parsed
        .map<CartProduct>((json) => CartProduct.fromJson(json))
        .toList();
  }

  //Delete icon calls this to delete a product from the cart
  Future<void> _deleteData(String? prodID) async {
    final token = await ProductstoreAuth().getToken();
    final response = await http.delete(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.cartEndpoint + '/$prodID'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', //Format sending
        'Authorization': 'Bearer $token',
        'ACCEPT': 'application/json', //Format recieving
      },
    );

/*
How I do the get request for example
    http.Request request = http.Request(
        'GET', Uri.parse(ApiConstants.baseUrl + ApiConstants.cartEndpoint));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving
*/

    if (response.statusCode == 200) {
      // Successful deletion
      print('Data deleted successfully');
      await refreshProductList();
    } else {
      // Failed to delete
      print('Failed to delete data: ${response.statusCode}');
    }
  }

  Future<void> refreshProductList() async {
    try {
      // Call getProducts function again to fetch updated list
      List<CartProduct>? updatedProductList = await getProducts("");
      if (updatedProductList != null) {
        setState(() {
          productList = updatedProductList;
        });
      }
    } catch (e) {
      print('Error refreshing product list: $e');
    }
  }

  @override
  //On wiget ini, getProducts function returns a future object and uses the then method to add a callback to update the list variable.
  void initState() {
    super.initState();
    getProducts("").then((ApiProductFromServer) {
      if (ApiProductFromServer != null) {
        setState(() {
          productList = ApiProductFromServer;
          //_totalResults = productList.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Shopping Cart'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.shopping_cart_checkout),
                onPressed: () {
                  RouteStateScope.of(context).go('/checkout');
                }),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 15,
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.all(5),
                itemCount: productList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle the click event here
                      //RouteStateScope.of(context).go('/product/0');
                      RouteStateScope.of(context)
                          .go('/apiproduct/${productList[index].item_number}');
                      //or try /apiproduct/:item_number
                      //print('Card ${productList[index].item_number} clicked!');
                    },
                    child: Card(
                      surfaceTintColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0), //card padding
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                child: Image.network(
                                  productList[index].image_urls[0],
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
                                padding:
                                    const EdgeInsets.fromLTRB(0, 15, 20, 15),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productList[index].item_description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        productList[index].item_number,
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        productList[index].uom_desc,
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        productList[index].pack_size,
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        productList[index].quantity,
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Price: \$${productList[index].price}',
                                        //If price is returned as a double convert to string and format to 2 decimal places.
                                        //'\$${productList[index].price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.green),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Total: \$${productList[index].extendedPrice}',
                                        //If price is returned as a double convert to string and format to 2 decimal places.
                                        //'\$${productList[index].price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          color: Colors.red[500],
                                          iconSize: 20.0,
                                          onPressed: () {
                                            _deleteData(productList[index]
                                                .id
                                                .toString());
                                          }),
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
            //Truck Minimums: BON51012 is a good example of a product that will count
            if (_truckEligibleSales != "")
              Expanded(
                flex: 2,
                child: Container(
                    color: Colors.grey[100],
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    child: Row(
                      children: [
                        Text(
                          'Truck Minimums:\nEligible items: \$${_truckEligibleSales} of \$600',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ),
            //Vendor Minimums: DSWCT936GN is a good example of a product with a vendor minimum
            if (_vendorMinimums != null)
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  child: ListView.builder(
                    itemCount: _vendorMinimums?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final key = _vendorMinimums.keys.toList()[index];
                      final value = _vendorMinimums[key];
                      final vendorName = value["vendor_name"];
                      final current_amount = value["current_amount"];
                      final min_amount = value["min_amount"];
                      //message_text and text_only should be set also
                      return Text(
                        'Vendor Minimums:\n' +
                            '${vendorName}: \$${current_amount} of \$${min_amount}',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            //Checkout button and Subtotal
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[100],
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Subtotal: \$${_subtotal}',
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                          onPressed: () {
                            RouteStateScope.of(context).go('/checkout');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary, // Set the background color
                            foregroundColor:
                                Colors.white, // Set the text color (optional)
                          ),
                          child: const Text('CHECKOUT',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
