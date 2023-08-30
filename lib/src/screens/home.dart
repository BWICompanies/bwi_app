// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../data/library.dart';
import '../routing.dart';

class HomeScreen extends StatelessWidget {
  final String title = 'Home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.green[700],
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 135, // same value as width to create a square
                color: Colors.grey[200], // specify the color of the square
                margin: EdgeInsets.only(bottom: 20),
              ),
              Expanded(
                child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20.0,
                    crossAxisSpacing: 20.0,
                    children: [
                      HomeCard(
                          Title: 'Scan Barcode', iData: Icons.qr_code_scanner),
                      HomeCard(Title: 'Catalog', iData: Icons.auto_stories),
                      HomeCard(Title: 'Promotions', iData: Icons.sell),
                      //HomeCard(Title: 'Track Order', iData: Icons.share_location),
                      //HomeCard(Title: 'Favorites', iData: Icons.favorite),
                      HomeCard(Title: 'Order History', iData: Icons.history),
                    ]),
              ),
            ],
          ),
        ),
      );
}

class HomeCard extends StatelessWidget {
  final String Title; //can be type widget even.
  final IconData iData;

  const HomeCard({required this.Title, required this.iData});

  @override
  Widget build(BuildContext context) {
    // Implement the custom widget's appearance and behavior using the provided parameters
    return InkWell(
      //onTap: () => _handleBookTapped(context, book),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Icon(
                iData,
                color: Colors.green[700],
                size: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                Title,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
