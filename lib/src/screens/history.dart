// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../data/library.dart';
import '../routing.dart';
//import 'package:http/http.dart' as http;
//import 'package:rest_api_example/constants.dart';
//import 'package:rest_api_example/model/user_model.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatelessWidget {
  final String title = 'History';

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.green[700],
        ),
        body: Text('History Page'),
      );
}
