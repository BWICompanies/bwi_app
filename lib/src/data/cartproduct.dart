//import 'dart:ffi';

class CartProduct {
  //Instance Variables
  var id;
  var user_id;
  var quantity;
  var item_number;
  var item_description;
  var uom;
  var created_at;
  var updated_at;
  var uom_desc;
  var pack_size;
  var image_urls;
  var price;
  var extendedPrice;
  var available;

  //The cart api will return truckEligibleSales, subtotal, and vendorMinimums as well, but those are outside of data[] and are not part of the CartProduct class.

  //Constructor
  CartProduct({
    required this.id, //parameters must be provided when creating the instance.
    required this.user_id,
    required this.quantity,
    required this.item_number,
    required this.item_description,
    required this.uom,
    required this.created_at,
    required this.updated_at,
    required this.uom_desc,
    required this.pack_size,
    required this.image_urls,
    required this.price,
    required this.extendedPrice,
    required this.available,
  });

  //factory method that accepts json map (associative array in PHP) and returns a CartProduct object. (Uses the constructor above to create and return an instance of the class)
  factory CartProduct.fromJson(Map<dynamic, dynamic> json) {
    return CartProduct(
      id: json['id'],
      user_id: json['user_id'],
      quantity: json['quantity'],
      item_number: json['item_number'],
      item_description: json['item_description'],
      uom: json['uom'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      uom_desc: json['uom_desc'],
      pack_size: json['pack_size'],
      image_urls: json['image_urls'],
      price: json['price'],
      extendedPrice: json['extendedPrice'],
      available: json['available'],
    );
  }

  /* example json:
  {
    "data": [
      {
        "id": 615271,
        "user_id": "19727",
        "quantity": "1",
        "item_number": "BON51012",
        "item_description": "Bamboo Stake Natural - 5' Tall x 7/16\" Diameter",
        "uom": "BN",
        "created_at": "2024-01-30T19:21:26.000000Z",
        "updated_at": "2024-01-30T19:21:26.000000Z",
        "uom_desc": "BUNDLE",
        "image_urls": [
          "https://bwi.nyc3.digitaloceanspaces.com/product-images/Lh0C5oYFrY6DFGceEeGUsJsMnq75IvD5uGbnG3Ez.jpg"
        ],
        "price": "55.71",
        "extendedPrice": "55.71",
        "available": 0
      }
    ],
    "truckEligibleSales": 55.71,
    "subtotal": 55.71,
    "vendorMinimums": []
  }
*/
}
