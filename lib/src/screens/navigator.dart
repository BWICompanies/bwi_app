/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.

///Also loads scaffold

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import '../data.dart';
import '../routing.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
import 'author_details.dart';
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
  final _authorDetailsKey = const ValueKey('Author details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = ProductstoreAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    Product? selectedProduct;
    if (pathTemplate == '/product/:productId') {
      selectedProduct = libraryInstance.allProducts.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['productId']);
    }

    Author? selectedAuthor;
    if (pathTemplate == '/author/:authorId') {
      selectedAuthor = libraryInstance.allAuthors.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['authorId']);
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /products or /authors tab in ProductstoreScaffold.
        if (route.settings is Page &&
            (route.settings as Page).key == _productDetailsKey) {
          routeState.go('/products/popular');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _authorDetailsKey) {
          routeState.go('/authors');
        }

        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.username, credentials.password);
                if (signedIn) {
                  await routeState.go('/home'); //Go to Home Screen if signed in
                }
              },
            ),
          )
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const ProductstoreScaffold(),
          ),
          // Add an additional page to the stack if the user is viewing a product
          // or an author
          if (selectedProduct != null)
            MaterialPage<void>(
              key: _productDetailsKey,
              child: ProductDetailsScreen(
                product: selectedProduct,
              ),
            )
          else if (selectedAuthor != null)
            MaterialPage<void>(
              key: _authorDetailsKey,
              child: AuthorDetailsScreen(
                author: selectedAuthor,
              ),
            ),
        ],
      ],
    );
  }
}
