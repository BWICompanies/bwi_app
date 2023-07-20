// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'author.dart';
import 'book.dart';

final libraryInstance = Library()
  ..addBook(
      title: 'AquaGro 2000 - 120 lb',
      item_number: 'AQ03',
      image_urls: 'https://images.bwicompanies.com/AQ03.jpg',
      authorName: 'AquaGro',
      price: 840.00,
      isPopular: true,
      isNew: true)
  ..addBook(
      title: 'Bamboo Stake Natural - 4\' Tall x 3/8" Diameter',
      item_number: 'BON40810',
      image_urls: 'https://images.bwicompanies.com/BON40810.jpg',
      authorName: 'Bamboo Supply Company',
      price: 82.45,
      isPopular: false,
      isNew: true)
  ..addBook(
      title: 'Sterling Irrigation Controller - 18 Zone',
      item_number: 'CASTRL18',
      image_urls: 'https://images.bwicompanies.com/CASTRL18.jpg',
      authorName: 'Superior Controls',
      price: 888.71,
      isPopular: true,
      isNew: false)
  ..addBook(
      title: 'Slip On Plant Tie - 8"',
      item_number: 'DA05TREES',
      image_urls: 'https://images.bwicompanies.com/DA05TREES.jpg',
      authorName: 'SATO America',
      price: 19.28,
      isPopular: false,
      isNew: false);

class Library {
  final List<Book> allBooks = [];
  final List<Author> allAuthors = [];

  void addBook({
    required String title,
    required String item_number,
    required String image_urls,
    required String authorName,
    required double price,
    required bool isPopular,
    required bool isNew,
  }) {
    var author = allAuthors.firstWhere(
      (author) => author.name == authorName,
      orElse: () {
        final value = Author(allAuthors.length, authorName);
        allAuthors.add(value);
        return value;
      },
    );

    //Order must match the order of the constructor in book.dart
    var book = Book(allBooks.length, title, item_number, image_urls, price,
        isPopular, isNew, author);

    author.books.add(book);
    allBooks.add(book);
  }

  List<Book> get popularBooks => [
        ...allBooks.where((book) => book.isPopular),
      ];

  List<Book> get newBooks => [
        ...allBooks.where((book) => book.isNew),
      ];
}
