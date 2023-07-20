//Layout for the list of products. (book list)

import 'package:flutter/material.dart';

import '../data.dart';

class BookList extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book>? onTap;

  const BookList({
    required this.books,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) => ListTile(
          dense: false,
          leading: Image.network(
            books[index].image_urls,
            width: 50,
            height: 50,
          ),
          title: Text(
            books[index].title,
          ),
          subtitle: Text(books[index].item_number
              //books[index].author.name,
              ),
          trailing: Text(
            '\$${books[index].price.toStringAsFixed(2)}', //Place $ before and Convert double to string with 2 decimal places
            style: TextStyle(fontSize: 16), // Set the font size to 18
          ),
          //Icon(Icons.star), //SizedBox(),
          onTap: onTap != null ? () => onTap!(books[index]) : null,
        ),
      );
}
