import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import '../data.dart';
import '../auth.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final String title = 'My Account';
  String accountnum = '';
  String name = '';
  String aac_salespname = '';
  String payterms = '';
  String creditlimit = '';
  String totaldue = '';

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

  //const AccountScreen({super.key});

  @override
  void initState() {
    super.initState();
    _getStringFromPrefs();
  }

  Future<void> _getStringFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      accountnum = prefs.getString('accountnum') ?? '';
      name = prefs.getString('name') ?? '';
      aac_salespname = prefs.getString('aac_salespname') ?? '';
      payterms = prefs.getString('payterms') ?? '';
      creditlimit = prefs.getString('creditlimit') ?? '';
      totaldue = prefs.getString('totaldue') ?? '';
    });
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
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
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
