/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
///Loads login page or scaffold and product detail if needed.
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import 'dart:convert'; //to and from json
import 'package:http/http.dart' as http; //for api requests

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
  //final _productDetailsKey = const ValueKey('Product details screen');
  //final _authorDetailsKey = const ValueKey('Author details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = ProductstoreAuthScope.of(context);
    String? item_number;

    //print("route.settings");
    //print(route.settings);

    //There is a bug where it sets it as the future when we only need to set it if its an ApiProduct.

    if (routeState.route.pathTemplate == '/apiproduct/:item_number') {
      item_number = 'FS101';
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        //pass in the route that was popped and the result passed to the popped route

        print("route");
        print(route);

        /*
        // When a product details page is popped, go back to products
        if (route.settings is Page &&
            (route.settings as Page).key == _productDetailsKey) { //if the pages key is the product details key, go back to products.
          routeState.go('/products');
        }
        */
        routeState.go('/products');
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
          if (item_number != null)
            MaterialPage<void>(
              key: ValueKey('Product details'),
              child: ProductDetailsScreen(
                item_number: item_number,
              ),
            )
        ],
      ],
    );
  }
}
