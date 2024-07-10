import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../data.dart';
import '../auth.dart';
import 'package:intl/intl.dart'; //for number formatting

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final String title = 'My Account';
  NumberFormat formatter = NumberFormat('0.00');

  //Vars populated from shared preferences using Authenticated User API endpoint
  String accountnum = '';
  String name = '';
  String aac_accountnum = '';
  String aac_salespname = '';
  String aac_payterms = '';
  String aac_creditlimit = '';
  double aac_creditlimit_dbl = 0.0;
  String aac_totaldue = '';
  double aac_totaldue_dbl = 0.0;

  //Vars populated from hitting Customer API endpoint
  String bill_to_address = '';
  String bill_to_city = '';
  String bill_to_state = '';
  String bill_to_zip5 = '';
  String bill_to_country = '';

  String ship_to_address = '';
  String ship_to_city = '';
  String ship_to_state = '';
  String ship_to_zip5 = '';
  String ship_to_country = '';

  @override
  void initState() {
    super.initState();
    _getStringsFromPrefs();
    _getCustomer(); //for addresses
  }

  Future<void> _getStringsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      accountnum = prefs.getString('accountnum') ?? '';
      aac_accountnum = prefs.getString('aac_accountnum') ?? '';
      name = prefs.getString('name') ?? '';
      aac_salespname = prefs.getString('aac_salespname') ?? '';
      aac_payterms = prefs.getString('aac_payterms') ?? '';
      aac_creditlimit = prefs.getString('aac_creditlimit') ?? '0.0';
      aac_creditlimit_dbl = double.parse(aac_creditlimit);
      aac_totaldue = prefs.getString('aac_totaldue') ?? '0.0';
      aac_totaldue_dbl = double.parse(aac_totaldue);
    });
  }

  Future _getCustomer() async {
    final token = await ProductstoreAuth().getToken();

    //print(token);
    //print('getShipping ran');

    //Hard coded for now but needs to pull Delivery Method Value
    http.Request request = http.Request(
        'GET',
        Uri.parse(ApiConstants.baseUrl +
            ApiConstants.customersEndpoint +
            "$aac_accountnum"));

    print(aac_accountnum);

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
              if (dataArray['freight'] != null) {
                try {
                  //_estShipping = double.parse(dataArray['freight'] as String);
                } on FormatException {
                  //print("Failed to parse freight as double");
                }
              } else {
                //print('Freight is null');
                //_estShipping = 0.0;
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
          ),
        ),
        //body: Text('test'),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Account Information',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Account Number: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: accountnum,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Account Name: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: name,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Salesperson: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: aac_salespname,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Terms: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: aac_payterms,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Credit Limit: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\$${formatter.format(aac_creditlimit_dbl)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'A/R Balance: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\$${formatter.format(aac_totaldue_dbl)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text('Bill-To Address',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                      child: Row(
                        children: [
                          Text("city"),
                          Text(
                              ", "), // Add comma and space between city and state
                          Text("state"),
                          Text(" "), // Add space between state and zip
                          Text("zip"),
                        ],
                      )),
                  Text('Ship-To Address',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                      child: Row(
                        children: [
                          Text("city"),
                          Text(
                              ", "), // Add comma and space between city and state
                          Text("state"),
                          Text(" "), // Add space between state and zip
                          Text("zip"),
                        ],
                      )),
                  ElevatedButton(
                      onPressed: () {
                        ProductstoreAuthScope.of(context).signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary, // Set the background color
                        foregroundColor:
                            Colors.white, // Set the text color (optional)
                      ),
                      child: const Text('Sign out',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)))
                ]),
          ),
        ),
      );

/*
  Future<String> readStringFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final myString = prefs.getString('active_account_name');
    return myString ?? 'No data';
  }
  */
}
