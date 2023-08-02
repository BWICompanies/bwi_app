//Main App File

//Sets allowed routes, set initial route, load navigator & handles auth
//Start at /signin (/screens/sign_in) or /books/popular (/screens/books.dart)

//App Notes:

//Catelog page is /screens/books.dart
//books.dart Sets Catalog App Bar & Tab Bar and loads ListView widget (booklist.dart)

//Product Details page is /screens/book_details.dart

//scaffold.dart contains: main navigation routes for the app
//and uses adaptive_navigation.dart package

//scaffold_body.dart displays the contents of the body of BookstoreScaffold
//Uses the Navigator Class to go to the correct screen.

//Flutters Scaffold widget provides components like AppBar, Body (Main content area), Floting Action Button, Bottom Navigation Bar, and Drawer.

//Screens with an AppBar
//books.dart,books_details.dart, authors.dart, author_datails.dart.

//Packages are imported in the pubspec.yaml file.

import 'package:flutter/material.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class Bookstore extends StatefulWidget {
  const Bookstore({super.key});

  @override
  State<Bookstore> createState() => _BookstoreState();
}

class _BookstoreState extends State<Bookstore> {
  final _auth = BookstoreAuth();
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
        '/home',
        '/history',
        '/settings',
        '/books/new',
        '/books/all',
        '/books/popular',
        '/book/:bookId',
        '/author/:authorId',
      ],
      guard: _guard,
      initialRoute: '/signin',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => BookstoreNavigator(
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
        child: BookstoreAuthScope(
          notifier: _auth,
          child: MaterialApp.router(
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeParser,
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
    final signedIn = _auth.signedIn;
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    // Go to /signin if the user is not signed in
    if (!signedIn && from != signInRoute) {
      return signInRoute;
    }
    // Go to /books if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/home', '/home', {}, {});
    }
    return from;
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
