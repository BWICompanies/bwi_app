// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'author.dart';

class Book {
  final int id;
  final String title;
  final String item_number;
  final String image_urls;
  final Author author;
  final bool isPopular;
  final bool isNew;
  final double price;

  //order must match library.dart file
  Book(this.id, this.title, this.item_number, this.image_urls, this.price,
      this.isPopular, this.isNew, this.author);
}
