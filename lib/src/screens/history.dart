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

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String title = 'History';
  //NumberFormat formatter = NumberFormat('0.00');
  //final _formKey = GlobalKey<FormState>();
  //String _asSelectedValue = '';

  @override
  void initState() {
    super.initState();
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                    child: Text('Open Orders   Purchase History',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal)),
                  ),
                  Text('Order# 18575225',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Date: ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "2024-07-15",
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
