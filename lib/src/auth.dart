import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import './constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart'; //for getting app version number
import 'package:pub_semver/pub_semver.dart'; //for comparing versions

class ProductstoreAuth extends ChangeNotifier {
  //Priviate class variables
  bool _signedIn = false;

  //List<String> accounts = ['EOTH076', 'TANB100', 'TACE500'];

  //getter methods to allow outside access to the private class variables
  bool get signedIn => _signedIn;
  //ie. _auth.signedIn or ProductstoreAuthScope.of(context).signedIn

  Future<bool> isTokenValid() async {
    String? currentToken = await this.getToken();

    //print(currentToken);

    //If token is there, see if it is valid
    if (currentToken != null) {
      //Make an authorized API call using the token to see if its valid
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $currentToken',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        //print('response is good');
        //debugPrint(response.body);
        _signedIn = true;
      } else {
        //print('response: ${response.statusCode}');
        _signedIn = false;
        //final prefs = await SharedPreferences.getInstance();
        //await prefs.clear();      }
      }
    } else {
      //Token is not there
      _signedIn = false;
    }

    return _signedIn;
  }

/*
  //If we want to use a package to check the expiration date of the token to save an api call if it is expired. But it calls api anyway if its still valid to confirm.
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      DateTime expirationDate = DateTime.parse(decodedToken['exp']);

      if (expirationDate.isBefore(DateTime.now())) {
        return false;
      }

      // Make an authorized API call using the token
      // If the API responds with a successful status code, the token is valid
      // If the API responds with an unauthorized status code, the token is invalid

      return true;
    } catch (e) {
      return false;
    }

  */

//Navigator runs .signIn when the user clicks the sign in button
  Future<String> signIn(String email, String password) async {
    //await checkMinVersion(); // Wait for version check

    //Verify min version before we allow the page to load
    bool needsUpdate = await this.checkMinVersion();

    //Dont login if we need to update. Let the next page do redirect.
    if (needsUpdate) {
      return 'Application needs update.';
    }

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.authEndpoint);

    final response = await http.post(url, body: {
      'email': email,
      'password': password,
      //'type': 'mobile-app',
      //'device_name': '', //await getDeviceId(),
    }, headers: {
      'Accept': 'application/json',
    });

    //print(response.statusCode); //429 "Too Many Requests,"

    if (response.statusCode == 200) {
      String token = response.body;
      //print(response.body);
      await saveToken(token);
      await saveUserData(token);
      _signedIn = true;
      notifyListeners();
      return 'Success';
    } else if (response.statusCode == 429) {
      _signedIn = false;
      return 'Too many requests. Please try again later.';
    } else if (response.statusCode == 401) {
      _signedIn = false;
      return 'Username or password is incorrect. Please try again.'; //was 422
    } else if (response.statusCode == 422) {
      _signedIn = false;
      return 'Username or password is incorrect. Please try again.'; //was 422
    } else {
      _signedIn = false;
      return 'Status code: ${response.statusCode}';
    }
  }
  //end sign in

  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  //Ran by signIn button click on login page and in the guard function in app.dart for other pages. True will redirect to update page.
  Future<bool> checkMinVersion() async {
    //print('auth checkMinVersion ran');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // Parse the string into a version number
    var currentVersionNumber = Version.parse(packageInfo.version);

    //print("current version of app: ${await PackageInfo.fromPlatform()}");
    //appName: navigation_and_routing, buildNumber: 10, packageName: navigation_and_routing, version: 1.2.0, buildSignature: , installerStore: null

    bool needsUpdate = false;

    //change this to a try. If it fails, we will just let the page load.
    final response = await http
        .get(Uri.parse('https://www.bwicompanies.com/mobile-app/min-version'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      var requiredVersionNumber = Version.parse(jsonData['version']);

      //If minimum version is less than or equal to the current version, do not have to update.
      if (currentVersionNumber < requiredVersionNumber) {
        //print("Current version is less than or equal to required version");
        needsUpdate = true;
      } else {
        needsUpdate = false;
      }
    } else {
      //throw Exception('Failed to fetch version');
      print('Failed to fetch version');
    }

    return needsUpdate;
  }
  //https://www.bwicompanies.com/mobile-app/min-version will return a version number {"version": "1.2.2"}

  saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  saveUserData(String token) async {
    final prefs = await SharedPreferences.getInstance();

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    //print(response);

    if (response.statusCode == 200) {
      //print(response.body);

      // Parse the JSON string and save to variable
      Map<String, dynamic> jsonData = json.decode(response.body);

      //Convert accounts to string to save to local storage
      final jsonString = jsonEncode(jsonData['data']['accounts']);
      await prefs.setString('accounts', jsonString);

      //Persist individual strings to local storage
      await prefs.setInt('userid', jsonData['data']['id']);
      await prefs.setString('name', jsonData['data']['name']);
      await prefs.setString('accountnum', jsonData['data']['accountnum']);
      await prefs.setString('email', jsonData['data']['email']);
      await prefs.setString('activeaccount', jsonData['data']['activeaccount']);
      await prefs.setString('type', jsonData['data']['type']);

      await prefs.setString(
          'active_account_name', jsonData['data']['active_account_name']);
      await prefs.setString('avatar_url', jsonData['data']['avatar_url']);
      //there is an active_account_customer array with a ton of information.

      await prefs.setString('aac_accountnum',
          jsonData['data']['active_account_customer']['accountnum']);
      await prefs.setString(
          'aac_name', jsonData['data']['active_account_customer']['name']);
      await prefs.setString('aac_shiptoname',
          jsonData['data']['active_account_customer']['shiptoname']);
      await prefs.setString('aac_salesperson',
          jsonData['data']['active_account_customer']['salesperson']);
      await prefs.setString('aac_salespname',
          jsonData['data']['active_account_customer']['salespname']);
      await prefs.setString('aac_porequired',
          jsonData['data']['active_account_customer']['porequired']);
      await prefs.setString('aac_totaldue',
          jsonData['data']['active_account_customer']['totaldue']);
      await prefs.setString('aac_creditlimit',
          jsonData['data']['active_account_customer']['creditlimit']);
      await prefs.setString('aac_markettype',
          jsonData['data']['active_account_customer']['markettype']);
      await prefs.setString('aac_mkttypedesc',
          jsonData['data']['active_account_customer']['mkttypedesc']);
      await prefs.setString('aac_payterms',
          jsonData['data']['active_account_customer']['payterms']);
      await prefs.setString('aac_contractonlyitems',
          jsonData['data']['active_account_customer']['contractonlyitems']);

      /*
      await prefs.setString(
          'c_accountnum', jsonData['data']['customer']['accountnum']);
      await prefs.setString('c_name', jsonData['data']['customer']['name']);
      await prefs.setString(
          'c_shiptoname', jsonData['data']['customer']['shiptoname']);
      await prefs.setString(
          'c_salesperson', jsonData['data']['customer']['salesperson']);
      await prefs.setString(
          'c_salespname', jsonData['data']['customer']['salespname']);
      await prefs.setString(
          'c_porequired', jsonData['data']['customer']['porequired']);
      await prefs.setString(
          'c_totaldue', jsonData['data']['customer']['totaldue']);
      await prefs.setString(
          'c_creditlimit', jsonData['data']['customer']['creditlimit']);
      await prefs.setString(
          'c_payterms', jsonData['data']['customer']['payterms']);
      await prefs.setString('c_contractonlyitems',
          jsonData['data']['customer']['contractonlyitems']);
      */
    } else {
      //print('Error: ${response.statusCode}');
      throw Exception('Problem loading user data');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ProductstoreAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}
//End ProductstoreAuth

class ProductstoreAuthScope extends InheritedNotifier<ProductstoreAuth> {
  const ProductstoreAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static ProductstoreAuth of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ProductstoreAuthScope>()!
      .notifier!;
}
