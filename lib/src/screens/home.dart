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
        body: Text('Homepage'),
      );
}
