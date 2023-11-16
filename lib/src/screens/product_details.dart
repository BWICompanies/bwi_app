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
      body: Center(
        child: Text(item_number ?? 'No item number'),
      ),
    );
  }
}
