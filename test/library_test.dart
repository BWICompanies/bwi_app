// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:bwiapp/src/data/library.dart';
import 'package:test/test.dart';

void main() {
  group('Library', () {
    test('addProduct', () {
      final library = Library();
      library.addProduct(
          title: 'Left Hand of Darkness',
          item_number: 'AQ03',
          image_urls:
              'https://bwi.nyc3.digitaloceanspaces.com/product-images/Lh0C5oYFrY6DFGceEeGUsJsMnq75IvD5uGbnG3Ez.jpg',
          authorName: 'Ursula K. Le Guin',
          description:
              'Natural in color. These poles are characterized by their straightness and smooth nodes. The primary use for these poles are tree stakes although they can be use for a variety of decorative purposes. They are extremely strong for their their thickness. The larger diameter on this size work well for curtain rods.',
          price: 0,
          isPopular: true,
          isNew: true);
      library.addProduct(
          title: 'Too Like the Lightning',
          item_number: 'AQ04',
          image_urls:
              'https://bwi.nyc3.digitaloceanspaces.com/product-images/Lh0C5oYFrY6DFGceEeGUsJsMnq75IvD5uGbnG3Ez.jpg',
          authorName: 'Ada Palmer',
          description:
              'Natural in color. These poles are characterized by their straightness and smooth nodes. The primary use for these poles are tree stakes although they can be use for a variety of decorative purposes. They are extremely strong for their their thickness. The larger diameter on this size work well for curtain rods.',
          price: 0,
          isPopular: false,
          isNew: true);
      library.addProduct(
          title: 'Kindred',
          item_number: 'AQ05',
          image_urls:
              'https://bwi.nyc3.digitaloceanspaces.com/product-images/Lh0C5oYFrY6DFGceEeGUsJsMnq75IvD5uGbnG3Ez.jpg',
          authorName: 'Octavia E. Butler',
          description:
              'Natural in color. These poles are characterized by their straightness and smooth nodes. The primary use for these poles are tree stakes although they can be use for a variety of decorative purposes. They are extremely strong for their their thickness. The larger diameter on this size work well for curtain rods.',
          price: 0,
          isPopular: true,
          isNew: false);
      library.addProduct(
          title: 'The Lathe of Heaven',
          item_number: 'AQ06',
          image_urls:
              'https://bwi.nyc3.digitaloceanspaces.com/product-images/Lh0C5oYFrY6DFGceEeGUsJsMnq75IvD5uGbnG3Ez.jpg',
          authorName: 'Ursula K. Le Guin',
          description:
              'Natural in color. These poles are characterized by their straightness and smooth nodes. The primary use for these poles are tree stakes although they can be use for a variety of decorative purposes. They are extremely strong for their their thickness. The larger diameter on this size work well for curtain rods.',
          price: 0,
          isPopular: false,
          isNew: false);
      expect(library.allAuthors.length, 3);
      expect(library.allAuthors.first.products.length, 2);
      expect(library.allProducts.length, 4);
      expect(library.allProducts.first.author.name, startsWith('Ursula'));
    });
  });
}
