//This is the Product Catalog screen (Products Screen in Example)
//Sets App Bar & Tab Bar
//Loads ProductList widget

import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/product_search_delegate.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Product Catalog'),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: ProductSearchDelegate() //(products: products)
                      );
                },
                icon: const Icon(Icons.search)),
            IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  RouteStateScope.of(context).go('/cart');
                }),
          ], //for i
          backgroundColor: Colors.green[700],
        ),
        body: Container(
            alignment: Alignment.center,
            child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('search here',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ])),
      );
}
