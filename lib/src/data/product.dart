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
  var longdesc;
  /*
  //Other options
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
    required this.longdesc,
    required this.image_urls,
    required this.price,
  });

  factory ApiProduct.fromJson(Map<dynamic, dynamic> json) {
    return ApiProduct(
      item_number: json['item_number'],
      item_description: json['item_description'],
      longdesc: json['longdesc'],
      image_urls: json['image_urls'],
      price: json['price'],
    );
  }

  /*
  Can dig into data here instead of in code.
  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(item_description: json['data']['item_description']);
  }
  */
}

/*
Example correct json response:
flutter: {"data":{"item_number":"FS101","item_description":"Ryegrass, Gulf Annual - 50 lb","longdesc":"This ryegrass is an erect, robust cool-season bunch grass that reaches a height of 3 to 4 ft. Plants are yellowish-green at the base and have 12\" long glossy leaves. This species has a heavy, extensive fibrous root system. Annual ryegrass has small seeds (approximately 190,000 seeds per pound) that germinate rapidly.","pack_size":"Pk/1","stocking_unit_of_measure":"BG","stocking_uom_desc":"BAG","sales_unit_of_measure":"BG","sales_uom_desc":"BAG","primary_vendor":"FS","vendor_name":"FARM SEEDS","market_type":"Retail","division":"Field Seed","class":"Forage Ryegrasses","mandatory_drop_ship":"N","ups_eligible":"N","item_status":"A","web_enabled":"Y","nosell":"N","stock_nonstock_item":"Y","upc":"021343701461","market_price":"N","add_timestamp":"1992-01-01 00:00:00.000000","update_timestamp":"2023-11-29 14:06:55.374059","image_urls":["https://bwi.nyc3.digitaloceanspaces.com/product-images/msotWPUqPiUKgapTk0U6L9eBHldiaBVXSNc1d8iI.jpg"],"is_new":false,"price":"40.35","uomData":{"BG":{"description":"BAG","mom":"1","pack_size":"Pk/1","price":"40.35","inventory":4154}},"qtyBreaks":[]}}
*/

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
