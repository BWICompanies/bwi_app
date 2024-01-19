//This is the Product Catalog screen
//Sets App Bar & Tab Bar. (Right now not using tabs.)
//Loads ProductList widget (Right now not using and reading api)

import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../auth.dart';

import '../data.dart';
import '../routing.dart';
//import '../widgets/product_search_delegate.dart';

import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:http/http.dart' as http; //for api requests

class ProductsScreen extends StatefulWidget {
  //final ValueChanged<Product>? onTap;

  const ProductsScreen({
    //this.onTap,
    super.key,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _debouncer = Debouncer(milliseconds: 500);

  //Defaults for pagination. The response will contain meta with current_page, from, path, per_page, and to. Page 1 will be from 1 to 10. Page 2 will be from 11 to 20.
  int _page = 0;
  var _prev = null;
  var _next = null;
  //int _totalResults = 0;
  var _pageMessage = "";
  //final int _pageSize = 10;
  //bool _hasNextPage = true;
  //bool _isLoading = false;

  List<ApiProduct> productList = []; //products returned from API

  Future<List<ApiProduct>?> getProducts(String? searchString) async {
    final token = await ProductstoreAuth().getToken();

    String? url;

    if (searchString != null && searchString.isNotEmpty) {
      url = ApiConstants.baseUrl +
          ApiConstants.searchEndpoint +
          "?q=$searchString&web_enabled=true&page=$_page"; //now instead of passing account=EOTH076 it will use the users active account.
    } else {
      url = ApiConstants.baseUrl +
          ApiConstants.itemsEndpoint +
          "?web_enabled=true&page=$_page"; //now instead of passing account=EOTH076 it will use the users active account.
    }

    http.Request request = http.Request('GET', Uri.parse(url));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';

    try {
      // Update to indicate that the streamedResponse and response variables can be null.
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        // Add a null check to the if statement before parsing the response.
        if (response != null) {
          //Parse response
          if (response.statusCode == 200) {
            //Parse Products in JSON data
            List<ApiProduct> list = parseData(response.body);

            //Parse the links and meta data for UI

            // Parse the JSON string into a Map
            Map<String, dynamic> jsonMap = jsonDecode(response.body);

            // Create the metaData object using the factory method
            ApiMetaData metaData = ApiMetaData.fromJson(jsonMap);

            //Create the apiLinks object using the factory method
            ApiLinks apiLinks = ApiLinks.fromJson(jsonMap);

            //debugPrint(response.body);

            _prev = apiLinks.prev;
            _next = apiLinks.next;
            _page = metaData.current_page;

            _pageMessage = "Page $_page";

            //_pageMessage = apiLinks.next;

            return list;
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

  //Read Json string and return a list of ApiProduct objects.
  //Return type is a list of objects of the type ApiProduct. This is a static class function, no need to create instance
  static List<ApiProduct> parseData(String responseBody) {
    // Decode the JSON response into a Dart object.
    final decodedResponse = json.decode(responseBody);

    // Get the data array from the decoded object.
    final dataArray = decodedResponse['data'] as List<dynamic>;

    // Parse the data array into a list of ApiProduct objects and return
    final parsed = dataArray.cast<Map<String, dynamic>>();
    return parsed.map<ApiProduct>((json) => ApiProduct.fromJson(json)).toList();
  }

  @override
  //On wiget ini, getProducts function returns a future object and uses the then method to add a callback to update the list variable.
  void initState() {
    super.initState();
    getProducts("").then((ApiProductFromServer) {
      if (ApiProductFromServer != null) {
        setState(() {
          productList = ApiProductFromServer;
          //_totalResults = productList.length;
        });
      }
    });
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    /*
    final TextEditingController _textEditingController =
        TextEditingController();
    */

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                RouteStateScope.of(context).go('/cart');
              }),
        ], //for i
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
        ),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _prev == null
                      ? null
                      : () {
                          // Handle button press for ElevatedButton
                        },
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20.0,
                    semanticLabel: 'Previous',
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary),
                    //disabledColor: Colors.lightGreen,
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity,
                          35), // Set height to 50, width to match parent
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius
                            .zero, // Set borderRadius to 0.0 for sharp corners
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: null,
                  child: Text(
                    "$_pageMessage",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary),
                    mouseCursor: MaterialStateProperty.all<MouseCursor>(
                        MouseCursor.defer),
                    overlayColor: MaterialStateProperty.all<Color>(
                        Colors.transparent), // Disable overlay effect
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity,
                          35), // Set height to 50, width to match parent
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius
                            .zero, // Set borderRadius to 0.0 for sharp corners
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _next == null
                      ? null
                      : () {
                          // Handle button press for ElevatedButton
                        },
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 20.0,
                    semanticLabel: 'Previous',
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary),
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(double.infinity,
                          35), // Set height to 50, width to match parent
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius
                            .zero, // Set borderRadius to 0.0 for sharp corners
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          //Search Bar to List of typed ApiProduct
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
                //controller: _textEditingController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  suffixIcon: InkWell(
                    child: Icon(Icons.search),
                  ),
                  contentPadding: EdgeInsets.all(15.0),
                  hintText: 'Search ',
                ),
                onChanged: (value) {
                  //print(value);

                  //run api on change and update products
                  _debouncer.run(() {
                    getProducts(value).then((ApiProductFromServer) {
                      if (ApiProductFromServer != null) {
                        setState(() {
                          // Set the productList variable to the ApiProductFromServer variable.
                          productList = ApiProductFromServer;
                          //_totalResults = productList.length;
                        });
                      }
                    });
                  });
                }),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.all(5),
              itemCount: productList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Handle the click event here
                    //RouteStateScope.of(context).go('/product/0');
                    RouteStateScope.of(context)
                        .go('/apiproduct/${productList[index].item_number}');
                    //or try /apiproduct/:item_number
                    //print('Card ${productList[index].item_number} clicked!');
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0), //card padding
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Image.network(
                                productList[index].image_urls[0],
                                //productList[index].image_urls, //was a string, now a list.
                                //'https://images.bwicompanies.com/DA05TREES.jpg', //if hardcode
                                //width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 20, 15),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productList[index].item_description,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      productList[index].item_number,
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.grey[600]),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '\$${productList[index].price}',
                                      //If price is returned as a double convert to string and format to 2 decimal places.
                                      //'\$${productList[index].price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.green),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
