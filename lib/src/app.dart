//Main App File

//Sets allowed routes, set initial route, load navigator & handles auth
//Start at /signin (/screens/sign_in) or /products (/screens/products.dart)

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
    // Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/signin',
        '/authors',
        '/scan',
        '/checkout',
        '/home',
        '/history',
        '/settings',
        '/account',
        '/products',
        '/cart',
        '/promos',
        //'/products/new',
        //'/products/all',
        //'/products/popular',
        //'/product/:productId',
        //'/author/:authorId',
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
              useMaterial3: true,
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontSize: 32),
                headlineMedium: TextStyle(fontSize: 24),
                //fontWeight: FontWeight.bold
                bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
                bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
                //to use: style: Theme.of(context).textTheme.headlineMedium,
              ),
              appBarTheme: const AppBarTheme(
                color: Colors.green,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              //colorSchemeSeed: Colors.green,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                primary: Colors.green[700],
                secondary: Colors.green[600],
                tertiary: Colors.green[900],
                surface: Colors.white,
                brightness: Brightness.light,
              ),
              cardColor: Colors.white,
              scaffoldBackgroundColor: Colors.grey[50],
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

  //thePage is the page we are checking to see if we can go to.
  Future<ParsedRoute> _guard(ParsedRoute thePage) async {
    //var signedIn = _auth.signedIn;

    //print($from);
    //After clicking a product should be set to:
    //flutter:<ParsedRoute template: /apiproduct/:item_number path: /apiproduct/BON51012 parameters: {item_number: BON51012} query parameters: {}>

    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    bool signedIn = await _auth.isTokenValid();

    //If not signed in, go to sign in
    if (!signedIn) {
      return signInRoute;
    } else {
      //Never return back to the signin page if already signed in
      if (thePage == signInRoute) {
        return ParsedRoute('/home', '/home', {}, {});
      } else {
        return thePage; //default is home, but can pass in where I was if I need to allow guests.
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
