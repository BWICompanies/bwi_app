/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
///Loads login page or scaffold and product detail if needed.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import 'dart:convert'; //to and from json
import 'package:http/http.dart' as http; //for api requests
import 'package:shared_preferences/shared_preferences.dart';

import '../auth.dart';
import '../data.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
//import 'author_details.dart';
import 'product_details.dart';
import 'scaffold.dart';

class ProductstoreNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ProductstoreNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<ProductstoreNavigator> createState() => _ProductstoreNavigatorState();
}

class _ProductstoreNavigatorState extends State<ProductstoreNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _scaffoldKey = const ValueKey('App scaffold');
  final _productDetailsKey = const ValueKey('Product details screen');
  //final _authorDetailsKey = const ValueKey('Author details screen');

  Future<String?> _getFrom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('from');
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = ProductstoreAuthScope.of(context);

    return Navigator(
      key: widget.navigatorKey,

      onPopPage: (route, dynamic result) {
        // When a product details page is popped, go back to products
        /*
        if (route.settings is Page &&
            (route.settings as Page).key == _productDetailsKey) {
          routeState.go('/products');
        }
        */

        //Get the from location to know where back button should go
        _getFrom().then((value) {
          if (value != null) {
            routeState.go(value);
          } else {
            routeState.go('/home');
          }
        });

        return route.didPop(result);
      },
      //Property that holds the pages to display. (List of Page objects)
      pages: [
        //Show the signin page or the ProductstoreScaffold that contains the navigation and the scaffold_body which loads the correct screen with a transition.
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen. (Logic in auth.dart, view in sign_in.dart)
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                //run auth.dart signIn function
                var signedIn = await authState.signIn(
                    credentials.email, credentials.password);
                if (signedIn) {
                  await routeState.go('/home'); //Go to Home Screen if signed in
                } else {
                  // Show an error message if sign in failed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username or password is incorrect'),
                    ),
                  );
                }
              },
            ),
          )
        //if not the signin screen, show the app scaffold which contains the menu and the scaffold_body which loads the correct screen with a transition and show a detail page on top if needed
        else ...[
          // Display the app scaffold
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const ProductstoreScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a product detail page
          if (routeState.route.parameters['item_number'] != null)
            MaterialPage<void>(
              key: _productDetailsKey,
              child: ProductDetailsScreen(
                item_number: routeState.route.parameters['item_number'],
              ),
            )
        ],
      ],
    );
  }
}
