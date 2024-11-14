import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; //optional but helps with debugging
import 'dart:convert'; //to and from json
import 'package:shared_preferences/shared_preferences.dart';
import '../routing.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
//import '../data.dart';
import '../auth.dart';
//import 'package:intl/intl.dart'; //for number formatting
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; //for checking if ios or not. (Platform.isIOS)
import 'package:package_info_plus/package_info_plus.dart'; //for getting app version number

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final String title = 'Update App';
  String updateURL = '';
  String currentVersionNumber = '';
  String requiredVersionNumber = '';

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> checkMinVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final response = await http
        .get(Uri.parse('https://www.bwicompanies.com/mobile-app/min-version'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final requiredVersion = jsonData['version'];

      setState(() {
        currentVersionNumber = currentVersion;
        requiredVersionNumber = requiredVersion;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkMinVersion();

    if (Platform.isIOS || Platform.isMacOS) {
      setState(() {
        updateURL =
            'https://apps.apple.com/us/app/bwi-product-catalog/id6463305061';
      });
    } else {
      setState(() {
        updateURL =
            'https://play.google.com/store/apps/details?id=com.bwicompanies.productcatalog';
        //'https://play.google.com/store/search?q=BWI%20Product%20Catalog&c=apps';
      });
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
                  Text('Update App',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "A required update has been uploaded. Please update your app in your app store.\n\nCurrent version: $currentVersionNumber\nRequired version: $requiredVersionNumber",
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
                        _launchURL(updateURL);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary, // Set the background color
                        foregroundColor:
                            Colors.white, // Set the text color (optional)
                      ),
                      child: const Text('Update',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)))
                ]),
          ),
        ),
      );
}
