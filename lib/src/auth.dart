import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import './constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import 'dart:convert';

//Navigator runs .signIn when the user clicks the sign in button
class ProductstoreAuth extends ChangeNotifier {
  //Priviate class variables
  bool _signedIn = false;
  //String _userName = "Guest";
  //List<String> accounts = ['EOTH076', 'TANB100', 'TACE500'];

  //getter methods to allow outside access to the private class variables
  bool get signedIn => _signedIn; //ie. yourInstance.signedIn
  //String get userName => _userName; //ProductstoreAuthScope.of(context).userName

  Future<bool> signIn(String email, String password) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.authEndpoint);

    final response = await http.post(url, body: {
      'email': email,
      'password': password,
      //'device_name': '', //await getDeviceId(),
    }, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      String token = response.body;
      await saveToken(token);
      await saveUserData(token);
      _signedIn = true;
      notifyListeners();
      return true;
    }

    if (response.statusCode == 422) {
      _signedIn = false;
      return false;
    }

    return false;
  }
  //end sign in

  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

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
    });

    if (response.statusCode == 200) {
      // Parse the JSON string and save to variable
      Map<String, dynamic> jsonData = json.decode(response.body);

      //Persist to local storage
      await prefs.setString('accountnum', jsonData['data']['accountnum']);
      await prefs.setString('activeaccount', jsonData['data']['activeaccount']);
      await prefs.setString('email', jsonData['data']['email']);
      await prefs.setInt('userid', jsonData['data']['id']);
      await prefs.setString('username', jsonData['data']['name']);
      await prefs.setString(
          'active_account_name', jsonData['data']['active_account_name']);
    } else {
      throw Exception('Problem loading books');
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
