//Uses the Navigator Class to go to the correct screen.

import 'package:flutter/material.dart';

import '../routing.dart';
import '../widgets/fade_transition_page.dart';
import '../screens/home.dart';
import '../screens/history.dart';
import '../screens/scan.dart';
import '../screens/checkout.dart';
import '../screens/cart.dart';
import '../screens/promos.dart';
import '../screens/settings.dart'; //not used right now
import '../screens/account.dart';
import '../screens/update.dart';
import '../screens/authors.dart';
import '../screens/products.dart';
import '../screens/products_promo.dart';
import '../screens/products_bb.dart';
import '../screens/scaffold.dart';

/// Displays the contents of the body of [ProductstoreScaffold]
class ProductstoreScaffoldBody extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const ProductstoreScaffoldBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;

/*
    String? contract_number;

    if (currentRoute.pathTemplate == '/products_promo/:contract_number') {
      contract_number = currentRoute.parameters['contract_number'];
      //OHPFALL24
    }
    */

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        if (currentRoute.pathTemplate.startsWith('/authors'))
          const FadeTransitionPage<void>(
            key: ValueKey('authors'),
            child: AuthorsScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/home'))
          const FadeTransitionPage<void>(
            key: ValueKey('home'),
            child: HomeScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/history'))
          const FadeTransitionPage<void>(
            key: ValueKey('history'),
            child: HistoryScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/scan'))
          const FadeTransitionPage<void>(
            key: ValueKey('scan'),
            child: ScanScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/checkout'))
          const FadeTransitionPage<void>(
            key: ValueKey('checkout'),
            child: CheckoutScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/settings'))
          const FadeTransitionPage<void>(
            key: ValueKey('settings'),
            child: SettingsScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/account'))
          const FadeTransitionPage<void>(
            key: ValueKey('account'),
            child: AccountScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/cart'))
          const FadeTransitionPage<void>(
            key: ValueKey('cart'),
            child: CartScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/promos'))
          const FadeTransitionPage<void>(
            key: ValueKey('promos'),
            child: PromoScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/update'))
          const FadeTransitionPage<void>(
            key: ValueKey('update'),
            child: UpdateScreen(),
          )
        else if (currentRoute.pathTemplate.startsWith('/products_promo'))
          FadeTransitionPage<void>(
            key: ValueKey('products_promo'),
            child: ProductsPromoScreen(
                contract_number: currentRoute.parameters['contract_number']),
          )
        else if (currentRoute.pathTemplate.startsWith('/products_bb'))
          FadeTransitionPage<void>(
            key: ValueKey('products_bb'),
            child: ProductsBBScreen(filter: currentRoute.parameters['filter']),
          )
        else if (currentRoute.pathTemplate.startsWith('/products') ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('products'),
            child: ProductsScreen(),
          )
        // Avoid building a Navigator with an empty `pages` list when the
        // RouteState is set to an unexpected path, such as /signin.
        //
        // Since RouteStateScope is an InheritedNotifier, any change to the
        // route will result in a call to this build method, even though this
        // widget isn't built when those routes are active.
        else
          FadeTransitionPage<void>(
            key: const ValueKey('empty'),
            child: Container(),
          ),
      ],
    );
  }
}
