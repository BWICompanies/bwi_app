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
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(24.0), // You can adjust the padding as needed
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
            ),
            GridView.builder(
              shrinkWrap: true, // Important to limit the height of the GridView
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns in the grid
              ),
              itemCount: 10, // Number of grid items
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ],
        ),
      )),
    );
  }
}
