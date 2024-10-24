// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import '../constants.dart'; //ie. var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
import 'package:http/http.dart' as http; //for api requests
import '../auth.dart';
import 'dart:convert'; //to and from json
import '../routing.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  //String _scanBarcode = '';

  @override
  void initState() {
    super.initState();

    //print('ini ran');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Promos'),
          actions: [
            IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  RouteStateScope.of(context).go('/cart');
                }),
          ],
          backgroundColor: Theme.of(context).colorScheme.primary,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
          ),
        ),
        body: Container(
            alignment: Alignment.center,
            child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Text('Loading...', style: const TextStyle(fontSize: 20)),
                  Text('Promos page.',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ])),
      );
}
