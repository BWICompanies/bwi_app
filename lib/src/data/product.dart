// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//import 'dart:ffi';
import 'author.dart'; //used for hard coded products only

//Declare Subject class for json data
class ApiProduct {
  var item_number;
  var item_description;
  var image_urls; //can use FlutterLogo(size: 72.0) for now
  var price;
  /*
  //Other options
  var longdesc;
  var pack_size;
  var stocking_unit_of_measure;
  var stocking_uom_desc;
  var sales_unit_of_measure;
  var sales_uom_desc;
  var primary_vendor;
  var vendor_name;
  var market_type;
  var division;
  //var class;
  var mandatory_drop_ship;
  var ups_eligible;
  var item_status;
  var web_enabled;
  var nosell;
  var stock_nonstock_item;
  var upc;
  var market_price;
  var add_timestamp;
  var update_timestamp;
  var is_new;
  var uomData;
  var qtyBreaks;
  */

  ApiProduct({
    required this.item_number,
    required this.item_description,
    required this.image_urls,
    required this.price,
  });

  factory ApiProduct.fromJson(Map<dynamic, dynamic> json) {
    return ApiProduct(
      item_number: json['item_number'],
      item_description: json['item_description'],
      image_urls: json['image_urls'],
      price: json['price'],
    );
  }
}

//Stuff for hard coded products
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
