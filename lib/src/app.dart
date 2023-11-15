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
      ],
      guard: _guard,
      initialRoute: '/signin',
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
    //var signedIn = _auth.signedIn; //starts off false.
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});
    final landingRoute = ParsedRoute('/home', '/home', {}, {});

    bool signedIn = await _auth.isTokenValid();

    //print(signedIn);

    if (!signedIn) {
      return signInRoute;
    } else {
      return landingRoute;
    }

    /*
    //Prevent odd situations
    //If not signed in and not coming from the sign in page, go to the sign in page.
    if (!signedIn && from != signInRoute) {
      print(
          "If not signed in and not coming from the sign in page, go to the sign in page.");
      return signInRoute;
    } else if (signedIn && from == signInRoute) { // Go home if the user is signed in and tries to go to /signin.
      print("Go home if the user is signed in and tries to go to /signin");
      return ParsedRoute('/home', '/home', {}, {});
    }
    */

    //Check for a valid token and set the signedIn variable to true if it is.
    //print("check for a valid token on the device");

/*
    //check to see if the token on the device is valid (Right now always returns true)
    _auth.isTokenValid().then((isTokenValid) {
      if (isTokenValid) {
        print('token is already valid, set sign in to true');
        //signedIn = true;
        return landingRoute;
      } else {
        print('token is not valid, set sign in to false');
        //signedIn = false;
        _auth.signOut(); //clears token from device
        return signInRoute;
      }

      //print("value of signedIn:");
      //print(signedIn);
    });
    */

    //return signin route until the token check is complete
    //print("return signin route until the token check is complete");
    //return from;
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
