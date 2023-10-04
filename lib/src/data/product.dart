// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//import 'dart:ffi';

import 'author.dart';

class Product {
  final int id;
  final String title;
  final String item_number;
  final String image_urls;
  final String description;
  final Author author;
  final bool isPopular;
  final bool isNew;
  final double price;
  final Map<String, dynamic> uom_data;

  //order must match library.dart file
  Product(
      this.id,
      this.title,
      this.item_number,
      this.image_urls,
      this.description,
      this.price,
      this.uom_data,
      this.isPopular,
      this.isNew,
      this.author);
}
