//This is the Product Catalog screen (Books Screen in Example)
//Sets App Bar & Tab Bar
//Loads BookList widget

import 'package:flutter/material.dart';

import '../data.dart';
import '../routing.dart';
import '../widgets/book_list.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({
    super.key,
  });

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_handleTabIndexChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newPath = _routeState.route.pathTemplate;
    if (newPath.startsWith('/books/popular')) {
      _tabController.index = 0;
    } else if (newPath.startsWith('/books/new')) {
      _tabController.index = 1;
    } else if (newPath == '/books/all') {
      _tabController.index = 2;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Product Catalog'),
          //Make a little darker
          backgroundColor: Colors.green[700],
          //Place the TabBar widget below the app Bar
          bottom: TabBar(
            controller: _tabController,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                  width: 2.0, color: Colors.white), // Change the color here
              insets: EdgeInsets.symmetric(
                  horizontal:
                      16.0), // Optional: You can add padding to the border
            ),
            tabs: const [
              Tab(
                text: 'Popular',
                icon: Icon(Icons.people),
              ),
              Tab(
                text: 'New',
                icon: Icon(Icons.new_releases),
              ),
              Tab(
                text: 'All',
                icon: Icon(Icons.list),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            BookList(
              books: libraryInstance.popularBooks,
              onTap: _handleBookTapped,
            ),
            BookList(
              books: libraryInstance.newBooks,
              onTap: _handleBookTapped,
            ),
            BookList(
              books: libraryInstance.allBooks,
              onTap: _handleBookTapped,
            ),
          ],
        ),
      );

  RouteState get _routeState => RouteStateScope.of(context);

  void _handleBookTapped(Book book) {
    _routeState.go('/book/${book.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 1:
        _routeState.go('/books/new');
      case 2:
        _routeState.go('/books/all');
      case 0:
      default:
        _routeState.go('/books/popular');
        break;
    }
  }
}
