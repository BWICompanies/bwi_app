import 'package:flutter/material.dart';
//import 'package:url_launcher/link.dart';
import 'dart:convert'; //to and from json
import 'package:http/http.dart' as http; //for api requests
import '../data.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);

class ProductDetailsScreen extends StatelessWidget {
  final String? item_number;

  //Constructor for this class that takes in a product object and the StatelessWidget key. (super keyword in dart is used to refer to the parent class for accessing properties, calling methods, and invoking constructors.)
  const ProductDetailsScreen({
    super.key,
    this.item_number,
  });

  @override
  //build method for this class that takes in a BuildContext object and returns a Widget object. BuildContext is a handle to the location of a widget in the widget tree.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('Product: '),
          Text(item_number ?? 'No item number'),
          //Text(product!.item_number),
        ]),
        backgroundColor: Colors.green[700],
      ),
      //Something in body is causing the error.
      body: Center(
        child: Column(
          children: [
            Text(
              "item_description here",
              //product!.item_description,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 32.0),
            Text(
              "image.network will go here.", //Maybe product!.image_urls[0]
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 32.0),
            Text(
              //product!.item_description,
              "item long description here",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 32.0),
            Text("add gridviewbuilder back here for uom stuff. Check search4"),
          ],
        ),
      ),
    );
  }
}
