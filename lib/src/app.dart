//Main App File

//Sets allowed routes, set initial route, load navigator & handles auth
//Start at /signin (/screens/sign_in) or /products/popular (/screens/products.dart)

//App Notes:

//Catelog page is /screens/products.dart
//products.dart Sets Catalog App Bar & Tab Bar and loads ListView widget (product_list.dart)

//Product Details page is /screens/product_details.dart

//scaffold.dart contains: main navigation routes for the app
//and uses adaptive_navigation.dart package

//scaffold_body.dart displays the contents of the body of ProductstoreScaffold
//Uses the Navigator Class to go to the correct screen.

//Flutters Scaffold widget provides components like AppBar, Body (Main content area), Floting Action Button, Bottom Navigation Bar, and Drawer.

//Screens with an AppBar
//products.dart,product_details.dart, authors.dart, author_datails.dart.

//Packages are imported in the pubspec.yaml file.

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';
//import 'package:provider/provider.dart';

class Productstore extends StatefulWidget {
  const Productstore({super.key});

  @override
  State<Productstore> createState() => _ProductstoreState();
}

class _ProductstoreState extends State<Productstore> {
  final _auth = ProductstoreAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/signin',
        '/authors',
        '/scan',
        '/home',
        '/history',
        '/settings',
        '/products/new',
        '/products/all',
        '/products/popular',
        '/product/:productId',
        '/author/:authorId',
        '/apiproduct/:item_number',
      ],
      guard: _guard,
      initialRoute: '/home',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => ProductstoreNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => RouteStateScope(
        notifier: _routeState,
        child: ProductstoreAuthScope(
          notifier: _auth,
          child: MaterialApp.router(
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeParser,
            debugShowCheckedModeBanner: false, //hide debug ribbon
            // Revert back to pre-Flutter-2.5 transition behavior:
            // https://github.com/flutter/flutter/issues/82053
            theme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: Colors.green[700],
              //accentColor: Colors.yellow[500],
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    //var signedIn = _auth.signedIn;

    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    bool signedIn = await _auth.isTokenValid();

    //If not signed in, go to sign in
    if (!signedIn) {
      return signInRoute;
    } else {
      //Never return back to the signin page if already signed in
      if (from == signInRoute) {
        return ParsedRoute('/home', '/home', {}, {});
      } else {
        return from; //default is home, but can pass in where I was if I need to allow guests.
      }
    }
  }

  void _handleAuthStateChanged() {
    if (!_auth.signedIn) {
      _routeState.go('/signin');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
