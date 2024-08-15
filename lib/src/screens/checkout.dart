import 'package:bwiapp/src/data/order.dart';
import 'package:flutter/material.dart';
import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:http/http.dart' as http; //for api requests
import 'package:shared_preferences/shared_preferences.dart';
import '../auth.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
//import '../data.dart';
import '../data/cartproduct.dart';
import '../data/order.dart';
import 'package:intl/intl.dart'; //for number formatting

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _checkoutVar = '';
  double _subtotal = 0.0;
  double? _estShipping;
  double? _estTaxes;
  double _orderTotal = 0.0; //doubles reduce redudant zeros
  NumberFormat formatter = NumberFormat('0.00');
  int _loading = 0; //0 = not loading, 1 = loading
  //to show redudant zeros use this. ie. formatter.format(_estTaxes)

  String aac_accountnum = '';
  String aac_name = '';
  String ship_to_attention_to = '';
  String ship_to_custname = '';
  String ship_to_address = '';
  String ship_to_city = '';
  String ship_to_state = '';
  String ship_to_zip5 = '';
  String ship_to_country = '';

  final _poController = TextEditingController();

  List<CartProduct> productList = []; //cart products returned from API
  final _formKey = GlobalKey<FormState>();
  Order _order = Order(); //create an instance of the Order class

  //Default drop down options
  List<DropdownMenuItem<String>> _deliveryOptions = [
    DropdownMenuItem<String>(
      value: '',
      child: Text('Select Delivery Method'),
    ),
  ];

  String _deliveryMethodSelectedValue = '';

  //Set default. Only load options if the delivery method is customer pick up
  List<DropdownMenuItem<String>> _pickupLocationOptions = [
    DropdownMenuItem<String>(
      value: 'N/A',
      child: Text('N/A'),
    ),
  ];

  String _pickupLocationSelectedValue = 'N/A';

  void deliveryMethodCallback(String? selectedValue) {
    if (selectedValue is String) {
      //If the user selects customer pick up, load the Get Pickup Locations from the api and populate the bwi location dropdown. Else, mark it inactive.
      if (selectedValue == 'PICK UP') {
        //Get the pickup locations from the api and populate the bwi location dropdown
        getPickupLocations();

        /*
        setState(() {
          _deliveryMethodSelectedValue = selectedValue;
        }); */
      } else {
        //Other is going to be Our Truck, Walk in, UOS or Fedex, etc.
        //print("Mark the bwi location dropdown inactive");

        //Reset the pickup location dropdown to N/A
        setState(() {
          // Clear existing items from locations dropdown
          _pickupLocationOptions.clear();
          _pickupLocationSelectedValue = '';

          // Add a default option to the pickup location dropdown
          _pickupLocationOptions.add(
            DropdownMenuItem(
              value: 'N/A',
              child: Text('N/A'),
            ),
          );

          _pickupLocationSelectedValue = 'N/A';
        });
      }

      //Update the delivery method selected value
      setState(() {
        _deliveryMethodSelectedValue = selectedValue;
      });

      //Recalc shipping based on new _deliveryMethodSelectedValue
      getShipping().then((value) {
        //Recalc order total
        setState(() {
          _orderTotal = _subtotal + (_estShipping ?? 0) + (_estTaxes ?? 0);
        });
      });
    } //end if the value is a string
  }

  void pickupLocationCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _pickupLocationSelectedValue = selectedValue;
      });
    }
  }

  Future getShipping() async {
    final token = await ProductstoreAuth().getToken();

    //print(token);
    //print('getShipping ran');

    //Hard coded for now but needs to pull Delivery Method Value
    http.Request request = http.Request(
        'GET',
        Uri.parse(ApiConstants.baseUrl +
            ApiConstants.shippingEndpoint +
            "?ship_via=$_deliveryMethodSelectedValue"));

    //print(_deliveryMethodSelectedValue);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        if (response != null) {
          //print(response.statusCode);

          //Parse response
          if (response.statusCode == 200) {
            // Decode the JSON response into a Dart object.
            final decodedResponse = json.decode(response.body);

            // Get the data array from the decoded object.
            final dataArray = decodedResponse['data'] as Map<String, dynamic>;
            //String, dynamic

            //print(dataArray);

            //Set the Pickup Location Options dropdown to the response from the api
            setState(() {
              //_estShipping = double.parse(dataArray['freight'] as String);
              //_estShipping =
              //double.tryParse(dataArray['freight'] ?? '') ?? 0.0;
              if (dataArray['freight'] != null) {
                try {
                  _estShipping = double.parse(dataArray['freight'] as String);
                } on FormatException {
                  //print("Failed to parse freight as double");
                }
              } else {
                //print('Freight is null');
                _estShipping = 0.0;
              }
            });

            //print(_estShipping);

            /* Example data:
            {
              "data": {
                "freight": null
              }
            }
            */

            return null;
          } else {
            return null;
          }
        } else {
          throw Exception('Error');
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future getTaxes() async {
    final token = await ProductstoreAuth().getToken();

    http.Request request = http.Request(
        'GET', Uri.parse(ApiConstants.baseUrl + ApiConstants.taxesEndpoint));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        if (response != null) {
          //print(response.statusCode);

          //Parse response
          if (response.statusCode == 200) {
            // Decode the JSON response into a Dart object.
            final decodedResponse = json.decode(response.body);

            // Get the data array from the decoded object.
            final dataArray = decodedResponse['data'] as Map<String, dynamic>;
            //String, dynamic

            //Set the Pickup Location Options dropdown to the response from the api
            setState(() {
              //_estTaxes = double.parse(dataArray['taxes'] as String);
              if (dataArray['taxes'] != null) {
                try {
                  _estTaxes = double.parse(dataArray['taxes'] as String);
                } on FormatException {
                  //print("Failed to parse taxes as double");
                }
              } else {
                //print('Taxes null');
                _estTaxes = 0.0;
              }
            });

            /* Example data:
            {
              "data": {
                "taxes": "1.52"
              }f
            }
            */

            return null;
          } else {
            return null;
          }
        } else {
          throw Exception('Error');
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future getDeliveryMethods() async {
    final token = await ProductstoreAuth().getToken();

    http.Request request = http.Request('GET',
        Uri.parse(ApiConstants.baseUrl + ApiConstants.deliveryMethodsEndpoint));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        if (response != null) {
          //print(response.statusCode);

          //Parse response
          if (response.statusCode == 200) {
            // Decode the JSON response into a Dart object.
            final decodedResponse = json.decode(response.body);

            // Get the data array from the decoded object.
            final dataArray = decodedResponse['data'] as Map<String, dynamic>;
            //String, dynamic

            //Set the Pickup Location Options dropdown to the response from the api
            setState(() {
              // Clear existing items
              //_deliveryOptions.clear();
              //_deliveryMethodSelectedValue = '';

              // Add dropdown options from the data array
              dataArray.forEach((key, value) {
                _deliveryOptions.add(
                  DropdownMenuItem(
                    value: key,
                    child: Text(value),
                  ),
                );
              });

              //_deliveryMethodSelectedValue = 'Select Pickup Location';
            });

            /* Example data:
            {
              "data": {
                "OUR TRUCK": "BWI TRUCK",
                "PICK UP": "CUSTOMER PICK UP"
              }
            }
            */

            return null;
          } else {
            return null;
          }
        } else {
          throw Exception('Error');
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future getPickupLocations() async {
    final token = await ProductstoreAuth().getToken();

    http.Request request = http.Request('GET',
        Uri.parse(ApiConstants.baseUrl + ApiConstants.pickupLocationsEndpoint));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        if (response != null) {
          //print(response.statusCode);

          //Parse response
          if (response.statusCode == 200) {
            // Decode the JSON response into a Dart object.
            final decodedResponse = json.decode(response.body);

            // Get the data array from the decoded object.
            final dataArray = decodedResponse['data'] as Map<String, dynamic>;
            //String, dynamic

            //Set the Pickup Location Options dropdown to the response from the api
            setState(() {
              // Clear existing items
              _pickupLocationOptions.clear();
              _pickupLocationSelectedValue = '';

              _pickupLocationOptions.add(
                DropdownMenuItem(
                  value: '',
                  child: Text('Select Pickup Location'),
                ),
              );

              // Add dropdown options from the data array
              dataArray.forEach((key, value) {
                _pickupLocationOptions.add(
                  DropdownMenuItem(
                    value: key,
                    child: Text(value),
                  ),
                );
              });

              _pickupLocationSelectedValue = '';
            });

            /*
            Example data
                        {
              "data": {
                "13": "Greenville\/Spartanburg Div - Greer, SC",
                "19": "Atlanta Branch - Norcross, GA"
              }
            }
            */

            return null;
          } else {
            return null;
          }
        } else {
          throw Exception('Error');
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //Return the products in the cart
  Future<List<CartProduct>?> getProducts(String? searchString) async {
    final token = await ProductstoreAuth().getToken();

    //print("getProducts running. _page is $_page");

    http.Request request = http.Request(
        'GET', Uri.parse(ApiConstants.baseUrl + ApiConstants.cartEndpoint));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      // Update to indicate that the streamedResponse and response variables can be null.
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        // Add a null check to the if statement before parsing the response.
        if (response != null) {
          //Parse response
          if (response.statusCode == 200) {
            //Parse Products in JSON data into an array
            List<CartProduct> list = parseData(response.body);

            //Get the subtotal and other data from the response that is outside of the data array

            // Parse the JSON string into a Map
            Map<String, dynamic> jsonMap = jsonDecode(response.body);

            _subtotal = double.parse(jsonMap['subtotal'].toString());

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

  //Submit the order when button pressed
  //Future<void> _updateData(String? prodID, String? uom, String? qty) async {
  Future<void> submitOrder(Order order) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing Data')),
    );

    try {
      final token = await ProductstoreAuth().getToken();

      // Create a POST request with the URL
      http.Request request = http.Request('POST',
          Uri.parse(ApiConstants.baseUrl + ApiConstants.checkoutEndpoint));

      //print(ApiConstants.baseUrl + ApiConstants.cartEndpoint);
      //getting a status code 404 for https://ct.bwicompanies.com/api/v1/cart

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json'; //Format sending
      request.headers['ACCEPT'] = 'application/json'; //Format recieving

      Map<String, dynamic> newData = {
        'order_type': "CART",
        'ship_method': _order.deliveryMethod,
        'po_number': _order.poNumber,
        // Add other keys and values as needed. There are columns in db for TAX AND FREIGHT but api doesnt allow submit becuase we do not persist that info.
      };

      //if ship method is customer pick up, add the bwi location to the data
      if (_order.deliveryMethod == 'PICK UP') {
        newData['pickup_location'] = _order.bwiLocation;
      }

      //print(json.encode(newData));
      //{"order_type":"CART","ship_method":"PICK UP","po_number":"","pickup_location":"13"}

      // Encode the new data as JSON and set it as the request body
      request.body = json.encode(newData);

      // Send the request
      http.StreamedResponse response = await request.send();

      // Check the status code of the response
      if (response.statusCode == 200) {
        print('Data updated successfully');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order Submitted Successfully.')),
        );
      } else {
        //print('Failed to update data. Response code: ${response.statusCode}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit order.')),
        );
      }
    } catch (e) {
      //print('Error updating data: $e');
      print('Error sending order.');
    }
  }

  //Read Json string and return a list of CartProduct objects.
  //Return type is a list of objects of the type CartProduct. This is a static class function, no need to create instance
  static List<CartProduct> parseData(String responseBody) {
    // Decode the JSON response into a Dart object.
    final decodedResponse = json.decode(responseBody);

    // Get the data array from the decoded object.
    final dataArray = decodedResponse['data'] as List<dynamic>;

    // Parse the data array into a list of ApiProduct objects and return
    final parsed = dataArray.cast<Map<String, dynamic>>();
    return parsed
        .map<CartProduct>((json) => CartProduct.fromJson(json))
        .toList();
  }

  Future _getCustomer() async {
    final token = await ProductstoreAuth().getToken();

    //print(token);

    http.Request request = http.Request(
        'GET',
        Uri.parse(ApiConstants.baseUrl +
            ApiConstants.customersEndpoint +
            "$aac_accountnum"));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json'; //Format sending
    request.headers['ACCEPT'] = 'application/json'; //Format recieving

    try {
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        if (response != null) {
          //print(response.statusCode);

          //Parse response
          if (response.statusCode == 200) {
            // Decode the JSON response into a Dart object.
            final decodedResponse = json.decode(response.body);

            // Get the data array from the decoded object.
            final dataArray = decodedResponse['data'] as Map<String, dynamic>;

            setState(() {
              //Shipping
              if (dataArray['shipping_address'] != null) {
                ship_to_attention_to =
                    dataArray['shipping_address']['attention_to'];
                ship_to_custname = dataArray['shipping_address']['custname'];
                ship_to_address = dataArray['shipping_address']['address'];
                ship_to_city = dataArray['shipping_address']['city'];
                ship_to_state = dataArray['shipping_address']['state'];
                ship_to_zip5 = dataArray['shipping_address']['zip5'];
                ship_to_country = dataArray['shipping_address']['country'];
              } else {
                //print('null');
              }
            });

            return null;
          } else {
            return null;
          }
        } else {
          throw Exception('Error');
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> getSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    aac_accountnum = prefs.getString('aac_accountnum') ?? '';
    aac_name = prefs.getString('aac_name') ?? '';

    //Pull shipping info from customer
    _getCustomer();
  }

  @override
  //On wiget ini, getProducts function returns a future object and uses the then method to add a callback to update the list variable.
  void initState() {
    super.initState();

    getSharedPref();

    getDeliveryMethods();

    getProducts("").then((ApiProductFromServer) {
      if (ApiProductFromServer != null) {
        getTaxes().then((value) {
          //print("The Taxes: $_estTaxes");

          getShipping().then((value) {
            //Now that we have the subtotal from getProducts and shipping and taxes, update variables and set state
            setState(() {
              productList = ApiProductFromServer;
              _orderTotal = _subtotal + (_estShipping ?? 0) + (_estTaxes ?? 0);
            });
          }); //end getShipping then
        }); //end getTaxes then
      }
    }); //end getProducts then
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Ship-To Address',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),

                  Divider(), //height:100, thickness: 2, color: Colors.blueGrey, indent: 20, endIndent: 20
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(ship_to_custname,
                            style: const TextStyle(fontSize: 14)),
                        Text(ship_to_attention_to,
                            style: const TextStyle(fontSize: 14)),
                        Text(ship_to_address,
                            style: const TextStyle(fontSize: 14)),
                        Text('$ship_to_city, $ship_to_state',
                            style: const TextStyle(fontSize: 14)),
                        Text(ship_to_zip5,
                            style: const TextStyle(fontSize: 14)),
                        SizedBox(height: 15.0),
                      ]),
                  Text('Shipping Details',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Divider(),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _poController,
                          /*
                          Do this if you want to make the PO number required
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a P.O. Number';
                            }
                            return null;
                          },*/
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'P.O. Number',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black38),
                              //width: 2.0
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black38),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 12),
                            labelStyle: TextStyle(fontSize: 16),
                            // Adjust padding
                          ),
                        ),
                        SizedBox(height: 15.0),
                        DropdownButtonFormField(
                          //iconSize: 24,
                          decoration: InputDecoration(
                            labelText: 'Delivery Method',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black38),
                              //width: 2.0
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black38),
                            ),
                          ),
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                          isExpanded: true,
                          items: _deliveryOptions,
                          onChanged: deliveryMethodCallback,
                          value: _deliveryMethodSelectedValue,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an option.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.0),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'BWI Location (Pickup Only)',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black38),
                              //width: 2.0
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.black38),
                            ),
                          ),
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                          isExpanded: true,
                          items: _pickupLocationOptions,
                          onChanged: pickupLocationCallback,
                          value: _pickupLocationSelectedValue,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an option.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.0),
                      ],
                    ),
                  ),
                  Text('Order Details',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      _subtotal != 0.0
                          ? 'Subtotal: \$${formatter.format(_subtotal)}'
                          : 'Subtotal: Loading...',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      _estShipping != null
                          ? 'Est. Shipping: \$${formatter.format(_estShipping)}'
                          : 'Est. Shipping: Loading...',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text(
                      _estTaxes != null
                          ? 'Est. Taxes: \$${formatter.format(_estTaxes)}'
                          : 'Est. Taxes: Loading...',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      'Order Total: \$${formatter.format(_orderTotal)}',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Center(
                      child: ElevatedButton(
                          onPressed: () {
                            //Validate and then run code to submit order.
                            //RouteStateScope.of(context).go('/buy-now');
                            //If validation passes, submit order and show thank you message.
                            if (_formKey.currentState!.validate()) {
                              _order.poNumber = _poController
                                  .text; //set the poNumber property of the Order object to the value of the poController text field
                              _order.deliveryMethod =
                                  _deliveryMethodSelectedValue; //add !; if nullable
                              _order.bwiLocation = _pickupLocationSelectedValue;

                              //call the submitOrder function
                              submitOrder(_order);

                              //If the form is valid, display a snackbar. In the real world, you'd often call a server or save the information in a database.
                              /*
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                              */
                            }

                            /*print(
                                "Validate and then submit order and show thank you message."); */
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary, // Set the background color
                            foregroundColor:
                                Colors.white, // Set the text color (optional)
                          ),
                          child: const Text('BUY NOW',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ]),
          ),
        ),
      );
}
