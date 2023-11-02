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
  //String _userAccountNum = "12345";
  //String _activeAccount = "12345";
  //String _accountStatus = "I";
  //bool _hasContract = false;
  //List<String> accounts = ['EOTH076', 'TANB100', 'TACE500'];

  /*
  How to loop in DART
  for (String fruit in accounts) {
    print(fruit);
  }
  */

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
      //List<dynamic> data = json.decode(response.body);

      // Parse the JSON string
      Map<String, dynamic> jsonData = json.decode(response.body);

      // Access the "accountnum" value
      String accountNum = jsonData['data']['accountnum'];

      await prefs.setString('accountnum', accountNum);

      /*
      for (int i = 0; i < data.length; i++) {
        books.add(Book.fromJson(data[i]));
      }
      */
      //return books;
    } else {
      throw Exception('Problem loading books');
    }

    /*
    await prefs.setString('accountnum', 'accountnum value');
    await prefs.setString('activeaccount', 'activeaccount value');
    await prefs.setString('email', 'email value');
    await prefs.setString('userid', 'userid value');
    await prefs.setString('username', 'username value');
    await prefs.setString('active_account_name', 'active_account_name value');
    */
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
