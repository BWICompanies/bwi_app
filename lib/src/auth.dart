// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// A mock authentication service
class ProductstoreAuth extends ChangeNotifier {
  //Priviate class variables
  bool _signedIn = false;
  String _userName = "Guest";
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
  String get userName => _userName; //ProductstoreAuthScope.of(context).userName

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    _signedIn = false;
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is ProductstoreAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

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
