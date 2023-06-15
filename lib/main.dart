import 'package:flutter/material.dart';
import 'package:rest_api_example/screens/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

/*
  class _MainPageState extends State<MainPage> {
  int currentIndex = 0; // default index of the bottom navigation bar


  final screens = [
    HomeScreen(),
    CatalogScreen(),
    ScanScreen(),
    HistoryScreen(),
    AccountScreen(),
  
  ];
 */

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: Home(),
    );
  }
}
