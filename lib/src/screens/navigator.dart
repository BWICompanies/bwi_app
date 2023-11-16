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
  final _productDetailsKey = const ValueKey('Product details screen');
  //final _authorDetailsKey = const ValueKey('Author details screen');

  //Build hook will call this to conditionally get the product detail if this is a detail page view
  Future<ApiProduct?> _GetProductDetail(BuildContext context) async {
    //print('_conditionallyGetProductDetail ran');
    await _getProduct("FS101");
  }

  //Function that gets the product from the api and returns it as an ApiProduct object
  Future<ApiProduct?> _getProduct(String? searchString) async {
    final token = await ProductstoreAuth().getToken();

    //print('getProduct ran');

    http.Request request = http.Request('GET',
        Uri.parse(ApiConstants.baseUrl + "/v1/items/FS101?account=EOTH076"));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';

    try {
      // Update to indicate that the streamedResponse and response variables can be null.
      var streamedResponse = await request.send();
      if (streamedResponse != null) {
        var response = await http.Response.fromStream(streamedResponse);

        // Add a null check to the if statement before parsing the response.
        if (response != null) {
          //Parse response
          if (response.statusCode == 200) {
            //ApiProduct selectedProduct = parseAgents(response.body);

            //print(response.body); //this is returning json data for the product if you are on a detail page

            //Turn the json into an object
            Map<String, dynamic> jsonMap = json.decode(response.body);
            ApiProduct jsonProduct = ApiProduct.fromJson(jsonMap);

            //print(jsonProduct); //This is returning an Instance of 'ApiProduct'

            return jsonProduct;
          } else {
            // Change the return type to indicate that the function may return a null value.
            return null;
          }
        } else {
          // Throw an exception if the response is null.
          throw Exception('Error');
        }
      } else {
        // Throw an exception if the streamedResponse is null.
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = ProductstoreAuthScope.of(context);
    ApiProduct? selectedProduct;

    //There is a bug where it sets it as the future when we only need to set it if its an ApiProduct.

    if (routeState.route.pathTemplate == '/apiproduct/:item_number') {
      //on product detail page returns an instance of Future<ApiProduct?>
      var results;
      results = _GetProductDetail(context);

      //If not a future, set the selectedProduct variable to the results
      if (!(results is Future)) {
        print('it ran');
        selectedProduct = results;
      }
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display products
        if (route.settings is Page &&
            (route.settings as Page).key == _productDetailsKey) {
          routeState.go('/products');
        }

        return route.didPop(result);
      },
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
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const ProductstoreScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a product detail page
          if (selectedProduct != null)
            MaterialPage<void>(
              key: _productDetailsKey,
              child: ProductDetailsScreen(
                product: selectedProduct,
              ),
            )
        ],
      ],
    );
  }
}
