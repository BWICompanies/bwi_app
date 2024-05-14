import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../data.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _checkoutVar = '';
  String _deliveryMethod = 'BWI Truck Delivery';
  String _pickupLocation = 'Select Pickup Location';

  void deliveryMethodCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _deliveryMethod = selectedValue;
      });
    }
  }

  void pickupLocationCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _pickupLocation = selectedValue;
      });
    }
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
                        Text('A & B FISK FARMS LLC',
                            style: const TextStyle(fontSize: 14)),
                        Text('BETTY FISK',
                            style: const TextStyle(fontSize: 14)),
                        Text('2020 EVANGELINE RD',
                            style: const TextStyle(fontSize: 14)),
                        Text('GLENMORA, LA',
                            style: const TextStyle(fontSize: 14)),
                        Text('71433 - 4510',
                            style: const TextStyle(fontSize: 14)),
                        SizedBox(height: 15.0),
                      ]),
                  Text('Shipping Details',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        //controller: _controller,
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
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                          labelStyle: TextStyle(fontSize: 16),
                          // Adjust padding
                        ),
                      ),
                      SizedBox(height: 7.0),
                      DropdownButtonFormField(
                          //iconSize: 24,
                          decoration: InputDecoration(
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
                          items: const [
                            DropdownMenuItem<String>(
                                child: Text('BWI Truck Delivery'),
                                value: 'BWI Truck Delivery'),
                            DropdownMenuItem<String>(
                                child: Text('Customer Pick up'),
                                value: 'Customer Pick up'),
                          ],
                          onChanged: deliveryMethodCallback,
                          value: _deliveryMethod),
                      SizedBox(height: 7.0),
                      DropdownButtonFormField(
                          decoration: InputDecoration(
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
                          items: const [
                            DropdownMenuItem<String>(
                                child: Text('Select Pickup Location'),
                                value: 'Select Pickup Location'),
                          ],
                          onChanged: pickupLocationCallback,
                          value: _pickupLocation),
                      SizedBox(height: 15.0),
                    ],
                  ),
                  Text('Order Details',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text('Order details here',
                        style: const TextStyle(fontSize: 14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: Center(
                      child: ElevatedButton(
                          onPressed: () {
                            RouteStateScope.of(context).go('/buy-now');
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
