//import 'dart:ffi';
import 'author.dart'; //used for hard coded products only

//ApiProduct class
class ApiProduct {
  //Instance Variables
  var item_number;
  var item_description;
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
  //var class; if I need to use this, we probably need to rename to something not protected.
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
  var image_urls; //can use FlutterLogo(size: 72.0) for a temp image
  var is_new;
  var price;
  var uomData;
  //final Map<String, dynamic> uomData;
  var qtyBreaks;

  //Constructor
  ApiProduct({
    required this.item_number, //parameters must be provided when creating the instance.
    required this.item_description,
    required this.longdesc,
    required this.pack_size,
    required this.stocking_unit_of_measure,
    required this.stocking_uom_desc,
    required this.sales_unit_of_measure,
    required this.sales_uom_desc,
    required this.primary_vendor,
    required this.vendor_name,
    required this.market_type,
    required this.division,
    required this.mandatory_drop_ship,
    required this.ups_eligible,
    required this.item_status,
    required this.web_enabled,
    required this.nosell,
    required this.stock_nonstock_item,
    required this.upc,
    required this.market_price,
    required this.add_timestamp,
    required this.update_timestamp,
    required this.image_urls,
    required this.is_new,
    required this.price,
    required this.uomData,
    required this.qtyBreaks,
  });

  //factory method that accepts json map (associative array in PHP) and returns an ApiProduct object. (Uses the constructor above to create and return an instance of the ApiProduct class)
  factory ApiProduct.fromJson(Map<dynamic, dynamic> json) {
    return ApiProduct(
      item_number: json['item_number'],
      item_description: json['item_description'],
      longdesc: json['longdesc'],
      pack_size: json['pack_size'],
      stocking_unit_of_measure: json['stocking_unit_of_measure'],
      stocking_uom_desc: json['stocking_uom_desc'],
      sales_unit_of_measure: json['sales_unit_of_measure'],
      sales_uom_desc: json['sales_uom_desc'],
      primary_vendor: json['primary_vendor'],
      vendor_name: json['vendor_name'],
      market_type: json['market_type'],
      division: json['division'],
      mandatory_drop_ship: json['mandatory_drop_ship'],
      ups_eligible: json['ups_eligible'],
      item_status: json['item_status'],
      web_enabled: json['web_enabled'],
      nosell: json['nosell'],
      stock_nonstock_item: json['stock_nonstock_item'],
      upc: json['upc'],
      market_price: json['market_price'],
      add_timestamp: json['add_timestamp'],
      update_timestamp: json['update_timestamp'],
      image_urls: json['image_urls'],
      is_new: json['is_new'],
      price: json['price'],
      uomData: json['uomData'],
      qtyBreaks: json['qtyBreaks'],
    );
  }

  /*
  Can dig into data here instead of in code. ie.
  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(item_description: json['data']['item_description']);
  }
  */
}

/*
Example correct json responses:
flutter: {"data":{"item_number":"FS101","item_description":"Ryegrass, Gulf Annual - 50 lb","longdesc":"","pack_size":"Pk/1","stocking_unit_of_measure":"BG","stocking_uom_desc":"BAG","sales_unit_of_measure":"BG","sales_uom_desc":"BAG","primary_vendor":"FS","vendor_name":"FARM SEEDS","market_type":"Retail","division":"Field Seed","class":"Forage Ryegrasses","mandatory_drop_ship":"N","ups_eligible":"N","item_status":"A","web_enabled":"Y","nosell":"N","stock_nonstock_item":"Y","upc":"021343701461","market_price":"N","add_timestamp":"1992-01-01 00:00:00.000000","update_timestamp":"2023-11-29 14:06:55.374059","image_urls":["https://bwi.nyc3.digitaloceanspaces.com/product-images/msotWPUqPiUKgapTk0U6L9eBHldiaBVXSNc1d8iI.jpg"],"is_new":false,"price":"40.35","uomData":{"BG":{"description":"BAG","mom":"1","pack_size":"Pk/1","price":"40.35","inventory":4154}},"qtyBreaks":[]}}

flutter: {"data":{"item_number":"BON61517","item_description":"Bamboo Stake Natural - 6' Tall x 5/8\" Diameter","longdesc":"Natural in color. These poles are characterized by their straightness and smooth nodes. The primary use for these poles are tree stakes although they can be use for a variety of decorative purposes. They are extremely strong for their their thickness. The larger diameter on this size work well for curtain rods.","pack_size":"Pk/100","stocking_unit_of_measure":"BN","stocking_uom_desc":"BUNDLE","sales_unit_of_measure":"BN","sales_uom_desc":"BUNDLE","primary_vendor":"BS2","vendor_name":"BAMBOO SUPPLY CO.","market_type":"Professional Grower","division":"Plant Supplies","class":"Bamboo","mandatory_drop_ship":"N","ups_eligible":"N","item_status":"A","web_enabled":"Y","nosell":"N","stock_nonstock_item":"Y","upc":"","market_price":"N","add_timestamp":"1992-01-01 00:00:00.000000","update_timestamp":"2023-11-30 05:45:24.389277","image_urls":["https://bwi.nyc3.digitaloceanspaces.com/product-images/OUmxiFt1Bccl7JyIMA1v0y8WEZaIwD7r5rLbzzn6.jpg"],"is_new":false,"price":"48.51","uomData":{"BN":{"description":"BUNDLE","mom":"1","pack_size":"Pk/100","price":"48.51","inventory":2}},"qtyBreaks":[]}}

*/

/////////////////////////////////
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
