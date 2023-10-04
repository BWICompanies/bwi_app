// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../data.dart';
import 'author_details.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product? product;
  //Product object variable is nullable and can not be changed once set.

  //Constructor for this class that takes in a product object and the StatelessWidget key. (super keyword in dart is used to refer to the parent class for accessing properties, calling methods, and invoking constructors.)
  const ProductDetailsScreen({
    super.key,
    this.product,
  });

  @override
  //build method for this class that takes in a BuildContext object and returns a Widget object. BuildContext is a handle to the location of a widget in the widget tree.
  Widget build(BuildContext context) {
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
          Text(product!.item_number),
        ]),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0), // You can adjust the padding as needed
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                product!.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 32.0),
              Image.network(
                product!.image_urls,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 32.0),
              Text(
                product!.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 32.0),
              /*
              Examples of linking to other pages.
              Text(
                product!.author.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              
              TextButton(
                child: const Text('View author (Push)'),
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          AuthorDetailsScreen(author: product!.author),
                    ),
                  );
                },
              ),
              Link(
                uri: Uri.parse('/author/${product!.author.id}'),
                builder: (context, followLink) => TextButton(
                  onPressed: followLink,
                  child: const Text('View author (Link)'),
                ),
              ),*/
              GridView.builder(
                shrinkWrap:
                    true, // Important to limit the height of the GridView
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns in the grid
                  //mainAxisSpacing: 8.0, // spacing between rows
                  //crossAxisSpacing: 8.0, // spacing between columns
                ),
                itemCount: product!.uom_data.length, // Number of grid items
                itemBuilder: (BuildContext context, int index) {
                  final uomKey = product!.uom_data.keys.elementAt(index);
                  //If you would rather do uom['description'] instead of
                  //product!.uom_data[uomKey]['description'] you can do this:
                  //final uom = product!.uom_data[uomKey];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0), //can use .only to do all 4 sides
                      child: Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, //by default, centers its children both horizontally and vertically.
                          //child: Text('Item $index'),
                          children: <Widget>[
                            Text(product!.uom_data[uomKey]['description'] +
                                " " +
                                product!.uom_data[uomKey]['pack_size']),
                            Text('\$${product!.uom_data[uomKey]['price']}'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Handle button press for ElevatedButton
                              },
                              child: Text('Add to Cart'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
