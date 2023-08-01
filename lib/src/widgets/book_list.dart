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
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) => ListTile(
          //leading can go here
          title: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Image.network(
                    books[index].image_urls,
                    width: 80,
                    height: 80,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          books[index].title,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 5),
                        Text(
                          books[index].item_number,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${books[index].price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ]),
                ),
              ],
            ),
          ),
          //title: Text('title $index'),
          //subtitle can go here
          //trailing can go here
          onTap: onTap != null ? () => onTap!(books[index]) : null,
        ),
      );
}
