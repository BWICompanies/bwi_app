// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../data.dart';
import 'author_details.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ApiProduct? product;
  //Product object variable is nullable and can not be changed once set.

  //Constructor for this class that takes in a product object and the StatelessWidget key. (super keyword in dart is used to refer to the parent class for accessing properties, calling methods, and invoking constructors.)
  const ProductDetailsScreen({
    super.key,
    this.product,
  });

  @override
  //build method for this class that takes in a BuildContext object and returns a Widget object. BuildContext is a handle to the location of a widget in the widget tree.
  Widget build(BuildContext context) {
    print('product details page loaded');
    print(product);

    if (product == null) {
      return const Scaffold(
        body: Center(
          child: Text('No product found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('Product: '),
          Text("item_number here"),
          //Text(product!.item_number),
        ]),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0), // You can adjust the padding as needed
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "item_description here",
                //product!.item_description,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 32.0),
              Image.network(
                //product!.image_urls[0],
                "https://boss.bwicompanies.com/item/FS101",
                fit: BoxFit.cover,
              ),
              SizedBox(height: 32.0),
              Text(
                //product!.item_description,
                "item long description here",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 32.0),
              Text(
                  "add gridviewbuilder back here for uom stuff. Check search4"),
            ],
          ),
        ),
      ),
    );
  }
}
