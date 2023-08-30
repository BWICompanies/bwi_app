//Layout for the list of products. (product list)

import 'package:flutter/material.dart';

import '../data.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product>? onTap;

  const ProductList({
    required this.products,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: products.length,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) => ListTile(
          //leading can go here
          title: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Image.network(
                    products[index].image_urls,
                    width: 80,
                    height: 80,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          products[index].title,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 5),
                        Text(
                          products[index].item_number,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${products[index].price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ]),
                ),
              ],
            ),
          ),
          //subtitle can go here
          //trailing can go here
          onTap: onTap != null ? () => onTap!(products[index]) : null,
        ),
      );
}
