import 'package:flutter/material.dart';
import 'home_page copy.dart';
import 'user_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    MyHomePage1(),
    MyUserPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            _showLogoutDialog();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        }, items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'rapports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    // Your logout dialog implementation
  }
} 