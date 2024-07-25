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
  final _formKey = GlobalKey<FormState>();
  String _asSelectedValue = '';

  //Default Account Selector Option
  List<DropdownMenuItem<String>> _asOptions = [
    DropdownMenuItem(value: '', child: Text('Loading...')),
  ];

  //Vars populated from shared preferences using Authenticated User API endpoint
  Map<String, dynamic> accountArray = {};
  Map<String, dynamic> accountArrayMerged = {};
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

  //When Active acount dropdown changes, update the active account variable in the database.
  void asCallback(String? selectedValue) {
    //print(selectedValue);

    setState(() {
      _asSelectedValue = selectedValue!;
    });
  }

  @override
  void initState() {
    super.initState();

    _getStringsFromPrefs().then((_) {
      _getCustomer(); //for addresses
      _populateActiveAccountDropdown();
    });
  }

  Future<void> _populateActiveAccountDropdown() async {
    setState(() {
      //Populate the dropdown with map

      _asOptions = accountArrayMerged.entries
          .map((entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList();

      //Set the active account as the default value
      _asSelectedValue = aac_accountnum;

      //Set the active account as the default value
      //_asSelectedValue = 'DCI2406';

      // Add the currently active account manually
      /*
      _asOptions.add(DropdownMenuItem<String>(
        value: aac_accountnum, // Assign a unique value
        child: Text(aac_accountnum), // Display text for the manual option
      ));

      //Set the default value to the currently active account
      _asSelectedValue = aac_accountnum;
      */
    });
  }

  Future<void> _getStringsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String accounts = prefs.getString('accounts') ?? '';

    //print(accountArray);
    //Map<String, String> _itemsMap = {}; // Initial empty map

    //Map of json accounts
    accountArray = json.decode(accounts);

    //Add active account to the map
    accountArray['ZCI0000'] = 'ZCI0000 (Active Account)';

    setState(() {
      //Variables
      accountArrayMerged = accountArray;
      accountnum = prefs.getString('accountnum') ?? '';
      aac_accountnum = prefs.getString('aac_accountnum') ?? '';
      name = prefs.getString('name') ?? '';
      aac_salespname = prefs.getString('aac_salespname') ?? '';
      aac_payterms = prefs.getString('aac_payterms') ?? '';
      aac_creditlimit = prefs.getString('aac_creditlimit') ?? '0.0';
      aac_creditlimit_dbl = double.parse(aac_creditlimit);
      aac_totaldue = prefs.getString('aac_totaldue') ?? '0.0';
      aac_totaldue_dbl = double.parse(aac_totaldue);

      //Use the following information to populate the dropdown.
      //print(aac_accountnum);

      // Iterate through the Map and print key-value pairs
      /*
      accountArray.forEach((key, value) {
        print('Key: $key, Value: $value');
      });
      */

      /*
      //If want to hard code something can use these instead of accountArray
      _itemsMap = {
        "DCI2406": "SUTHERLAND LBR #2406",
        "DCI2408": "SUTHERLAND LBR #2408",
        "DCI2810": "SUTHERLAND LBR #2810",
      }; 
      */

      //Populate the dropdown with map
      /*
      _asOptions = accountArray.entries
          .map((entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList();

      _asSelectedValue = 'DCI2406';
*/
      // Add the currently active account manually
/*
      _asOptions.add(DropdownMenuItem<String>(
        value: aac_accountnum, // Assign a unique value
        child: Text(aac_accountnum), // Display text for the manual option
      ));
*/

      //Set the default value to the currently active account
      //_asSelectedValue = 'ZCI0000';
      //DCI2408 works, ZCI0000 doesnt, aac_accountnum doesnt;
    });
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
              //Billing
              if (dataArray['billing_address'] != null) {
                bill_to_address = dataArray['billing_address']['address'];
                bill_to_city = dataArray['billing_address']['city'];
                bill_to_state = dataArray['billing_address']['state'];
                bill_to_zip5 = dataArray['billing_address']['zip5'];
                bill_to_country = dataArray['billing_address']['country'];
              } else {
                //print('null');
              }

              //Shipping
              if (dataArray['shipping_address'] != null) {
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
                  Text(bill_to_address),
                  Row(
                    children: [
                      Text(bill_to_city),
                      Text(", "), // Add comma and space between city and state
                      Text(bill_to_state),
                      Text(" "), // Add space between state and zip
                      Text(bill_to_zip5),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                    child: Text(bill_to_country),
                  ),
                  Text('Ship-To Address',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Text(ship_to_address),
                  Row(
                    children: [
                      Text(ship_to_city),
                      Text(", "), // Add comma and space between city and state
                      Text(ship_to_state),
                      Text(" "), // Add space between state and zip
                      Text(ship_to_zip5),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                    child: Text(ship_to_country),
                  ),
                  Text('Active Account',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 14),
                    child: DropdownButtonFormField(
                      //iconSize: 24,
                      decoration: InputDecoration(
                        //labelText: 'Active Account',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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
                      items: _asOptions,
                      onChanged: asCallback,
                      value: _asSelectedValue ?? '',
                      /*
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an option.';
                        }
                        return null;
                      },
                      */
                    ),
                  ),
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
