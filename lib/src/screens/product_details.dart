import 'package:flutter/material.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import 'dart:convert'; //to and from json
import '../auth.dart';
//import 'package:url_launcher/link.dart';
import 'package:http/http.dart' as http; //for api requests
import '../data.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? item_number;

  //Constructor for this class that takes in a product object and the StatelessWidget key. (super keyword in dart is used to refer to the parent class for accessing properties, calling methods, and invoking constructors.)
  ProductDetailsScreen({super.key, this.item_number});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ApiProduct? selectedProduct;

  //Function that gets the product from the api and returns it as an ApiProduct object (Runs on initState)
  Future<ApiProduct?> _getProduct(String? searchString) async {
    final token = await ProductstoreAuth().getToken();

    //If need token for testing in insomnia
    //print(token);

    http.Request request = http.Request(
        'GET',
        Uri.parse(ApiConstants.baseUrl +
            "/v1/items/$searchString")); //now instead of passing account=EOTH076 it will use the users active account.

    //Hard code for testing
    //Uri.parse(ApiConstants.baseUrl + "/v1/items/FS101?account=EOTH076"));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';

    try {
      // Update to indicate that the streamedResponse and response variables can be null.
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        //returns 404
        //print(response.statusCode);

        // Add a null check to the if statement before parsing the response.
        if (response != null) {
          //Turn the json response into an object
          if (response.statusCode == 200) {
            //turn json into map (associative array in PHP)
            Map<String, dynamic> jsonMap = json.decode(response.body);
            //turn map/associative array into an object using the factory method in product.dart
            ApiProduct jsonProduct = ApiProduct.fromJson(jsonMap['data']);

            //print(response.body);
            //print(jsonProduct.item_description);

            return jsonProduct;
          } else {
            // Change the return type to indicate that the function may return a null value.
            return null;
          }
        } else {
          // Throw an exception if the response is null.
          throw Exception('Error');
        }
      } else {
        // Throw an exception if the streamedResponse is null.
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //On wiget ini, set selectedProduct. (_getProduct function returns a future object and uses the then method to add a callback to update the selectedProduct variable.)
  void initState() {
    super.initState();
    _getProduct(widget.item_number).then((ApiProductFromServer) {
      //widget.item_number
      if (ApiProductFromServer != null) {
        setState(() {
          selectedProduct = ApiProductFromServer;
        });
      }
    });
  }

  @override
  //build method for this class that takes in a BuildContext object and returns a Widget object. BuildContext is a handle to the location of a widget in the widget tree.
  Widget build(BuildContext context) {
    //print(selectedProduct?.item_description); //null safe way to print

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('Product: '),
          Text(widget.item_number ?? 'No item number'),
          //Text(product!.item_number), //! will tell dart its non-nullable. (will throw an error if null)
        ]),
        backgroundColor: Colors.green[700],
      ),
      //Something in body is causing the error.
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          //scrollable view
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns children to the start (left)
            children: [
              Text(
                selectedProduct?.item_description ?? 'Loading...',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 32.0),
              //Show BWI logo while getting the product info or if it doesnt have one.
              Center(
                child: Image.network(
                  selectedProduct?.image_urls?[0] ??
                      'https://www.bwicompanies.com/images/MISC/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 32.0),
              Text(
                selectedProduct?.longdesc ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 32.0),
              Text(
                "Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 15.0),
              Text("Vendor: ${selectedProduct?.vendor_name ?? ''}"),
              Text("UPC: ${selectedProduct?.upc ?? ''}"),
              SizedBox(height: 32.0),
              Text(
                  "add gridviewbuilder back here for uom stuff. Check search4"),
            ],
          ),
        ),
      ),
    );
  }
}
