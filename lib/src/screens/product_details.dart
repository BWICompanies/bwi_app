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
  ApiProduct? selectedProduct; //nullable product object

  //Function that gets the product from the api and returns it as an ApiProduct object (Runs on initState)
  Future<ApiProduct?> _getProduct(String? searchString) async {
    final token = await ProductstoreAuth().getToken();

    //If need token for testing in insomnia
    //print(token);

    http.Request request = http.Request(
        'GET',
        Uri.parse(ApiConstants.baseUrl +
            ApiConstants.itemsEndpoint +
            "/$searchString")); //now instead of passing account=EOTH076 it will use the users active account.

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
        ),
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
              SizedBox(height: 25.0),
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
              SizedBox(height: 25.0),
              Text(
                "Options",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 15.0),
              //Only load uom cards if the product has loaded
              selectedProduct != null
                  ? GridView.builder(
                      shrinkWrap:
                          true, // Important to limit the height of the GridView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // Number of columns in the grid
                        mainAxisSpacing: 0.0, // spacing between rows
                        crossAxisSpacing: 6.0, // spacing between columns
                        mainAxisExtent: 185, // row height
                        //childAspectRatio: 1 / 2,
                      ),
                      itemCount: selectedProduct!
                          .uomData.length, // Number of grid items
                      itemBuilder: (BuildContext context, int index) {
                        final uomKey =
                            selectedProduct!.uomData.keys.elementAt(index);
                        //If you would rather do uom['description'] instead of
                        //product!.uom_data[uomKey]['description'] you can do this:
                        //final uom = product!.uom_data[uomKey];
                        //String _uomSelected = product!.uom_data.keys.first;

                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal:
                                    15.0), //can use .only to do all 4 sides
                            child: Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, //by default, centers its children both horizontally and vertically.
                                //child: Text('Item $index'),
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(
                                        selectedProduct!.uomData[uomKey]
                                                ['description'] +
                                            " " +
                                            selectedProduct!.uomData[uomKey]
                                                ['pack_size'],
                                        style: TextStyle(
                                          fontSize: 17.0, // Font size
                                          color:
                                              Colors.green[700], // Text color
                                          fontWeight:
                                              FontWeight.bold, // Font weight
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        '\$${selectedProduct!.uomData[uomKey]['price']}',
                                        style: TextStyle(
                                          fontSize: 17.0, // Font size
                                          fontWeight:
                                              FontWeight.bold, // Font weight
                                        ),
                                      ), //use variable wrapper for $
                                    ],
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Quantity',
                                      //border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0,
                                          horizontal: 0), // Adjust padding
                                    ),
                                    //decoration: InputDecoration(labelText: 'Enter your text',),
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    width: double
                                        .infinity, // Set the width to fill the parent's width
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Handle button press for ElevatedButton
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700]),
                                      child: Text(
                                        'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Text(''), //variable is null, dont show cards
            ],
          ),
        ),
      ),
    );
  }
}
