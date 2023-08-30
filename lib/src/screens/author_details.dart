// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/product_list.dart';

class AuthorDetailsScreen extends StatelessWidget {
  final Author author;

  const AuthorDetailsScreen({
    super.key,
    required this.author,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(author.name),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ProductList(
                  products: author.products,
                  onTap: (product) {
                    RouteStateScope.of(context).go('/product/${product.id}');
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
