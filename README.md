# Keyboard Shortcuts
stless make a stateless widget
stful make a stateful widget
Windows: CTRL + SHIFT + R or CTRL + . to wrap a widget. (My keyboard command .)
Can comand click something to see its source also.

# Navigation and Routing
A sample that shows how to use the [Router][] API to handle common navigation
scenarios.

## Goals
- Demonstrate common navigation scenarios:
  - Parsing path parameters ('/user/:id')
  - Sign in (validation / guards)
  - Nested navigation
- Provide a reusable implementation of RouterDelegate and RouteInformationParser
- Demonstrate how [deep linking][] is configured on iOS and Android
- Demonstrate how to use the Link widget from `package:url_Launcher` with the
  Router API.

## How it works
The top-level widget, `Productstore`, sets up the state for this app. It places
three `InheritedNotifier` widgets in the tree: `RouteStateScope`,
`ProductstoreAuthScope`, and `LibraryScope`, which provide the state for the
application:

  - **`RouteState`**: stores the current route path (`/product/1`) as a `ParsedRoute`
    object (see below).
  - **`ProductstoreAuthScope`**: stores a mock authentication API, `ProductstoreAuth`.
  - **`LibraryScope`**: stores the data for the app, `Library`.

The `Productstore` widget also uses the [MaterialApp.router()][router-ctor]
constructor to opt-in to the [Router][] API. This constructor requires a
[RouterDelegate][] and [RouteInformationParser][]. This app uses the
`routing.dart` library, described below.

## routing.dart
This library contains a general-purpose routing solution for medium-sized apps.
It implements these classes:

- **`SimpleRouterDelegate`**: Implements `RouterDelegate`. Updates `RouteState` when
  a new route has been pushed to the application by the operating system. Also
  notifies the `Router` widget whenever the `RouteState` changes.
- **`TemplateRouteParser`**: Implements RouteInformationParser. Parses the
  incoming route path into a `ParsedRoute` object. A `RouteGuard` can be
  provided to guard access to certain routes.
- **`ParsedRoute`**: Contains the current route location ("/user/2"), path
  parameters ({id: 2}), query parameters ("?search=abc"), and path template
  ("/user/:id")
- **`RouteState`**: Stores the current `ParsedRoute`.
- **`RouteGuard`**: Guards access to routes. Can be overridden to redirect the
  incoming route if a condition isn't met.

## App Structure

The `SimpleRouterDelegate` constructor requires a `WidgetBuilder` parameter and
a `navigatorKey`. This app uses a `ProductstoreNavigator` widget, which configures
a `Navigator` with a list of pages, based on the current `RouteState`.

```dart
SimpleRouterDelegate(
  routeState: routeState,
  navigatorKey: navigatorKey,
  builder: (context) => ProductstoreNavigator(
    navigatorKey: navigatorKey,
  ),
);
```

This `Navigator` is configured to display either the sign-in screen or the
`ProductstoreScaffold`. An additional screen is stacked on top of the
`ProductstoreScaffold` if a product or author is currently selected:

```dart
return Navigator(
  key: widget.navigatorKey,
  onPopPage: (route, dynamic result) {
    // ...
  },
  pages: [
    if (routeState.route.pathTemplate == '/signin')
      FadeTransitionPage<void>(
        key: signInKey,
        child: SignInScreen(),
      ),
    else ...[
      FadeTransitionPage<void>(
        key: scaffoldKey,
        child: ProductstoreScaffold(),
      ),
      if (selectedProduct != null)
        MaterialPage<void>(
          key: productDetailsKey,
          child: ProductDetailsScreen(
            product: selectedProduct,
          ),
        )
      else if (selectedAuthor != null)
        MaterialPage<void>(
          key: authorDetailsKey,
          child: AuthorDetailsScreen(
            author: selectedAuthor,
          ),
        ),
    ],
  ],
);
```

The `ProductstoreScaffold` widget uses `package:adaptive_navigation` to build a
navigation rail or bottom navigation bar based on the size of the screen. The
body of this screen is `ProductstoreScaffoldBody`, which configures a nested
Navigator to display either the `AuthorsScreen`, `SettingsScreen`, or
`ProductsScreen` widget.

## Linking vs updating RouteState

There are two ways to change the current route, either by updating `RouteState`,
which the RouterDelegate listens to, or use the Link widget from
`package:url_launcher`. The `SettingsScreen` widget demonstrates both options:

```
Link(
  uri: Uri.parse('/product/0'),
  builder: (context, followLink) {
    return TextButton(
      child: const Text('Go directly to /product/0 (Link)'),
      onPressed: followLink,
    );
  },
),
TextButton(
  child: const Text('Go directly to /product/0 (RouteState)'),
  onPressed: () {
    RouteStateScope.of(context)!.go('/product/0');
  },
),
```

## Questions/issues

If you have a general question about the Router API, the best places to go are:

- [The FlutterDev Google Group](https://groups.google.com/forum/#!forum/flutter-dev)
- [StackOverflow](https://stackoverflow.com/questions/tagged/flutter)

If you run into an issue with the sample itself, please file an issue
in the [main Flutter repo](https://github.com/flutter/flutter/issues).

[Router]: https://api.flutter.dev/flutter/widgets/Router-class.html
[RouterDelegate]: https://api.flutter.dev/flutter/widgets/RouterDelegate-class.html
[RouteInformationParser]: https://api.flutter.dev/flutter/widgets/RouteInformationParser-class.html
[router-ctor]: https://api.flutter.dev/flutter/material/MaterialApp/MaterialApp.router.html
[deep linking]: https://flutter.dev/docs/development/ui/navigation/deep-linking
