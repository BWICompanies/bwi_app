import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0; // default index of the bottom navigation bar

/*
  final screens = [
    HomeScreen(),
    CatalogScreen(),
    ScanScreen(),
    HistoryScreen(),
    AccountScreen(),
*/
  final screens = [
    const Center(child: Text('Home', style: TextStyle(fontSize: 30))),
    const Center(child: Text('Catalog', style: TextStyle(fontSize: 30))),
    const Center(child: Text('Scan', style: TextStyle(fontSize: 30))),
    const Center(child: Text('History', style: TextStyle(fontSize: 30))),
    const Center(child: Text('Account', style: TextStyle(fontSize: 30))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(
            () => currentIndex = index), //update currentIndex state on tap
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        iconSize: 26,
        selectedFontSize: 16,
        unselectedFontSize: 14,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(.60),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), //https://fonts.google.com/icons
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), //center_focus_strong
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
