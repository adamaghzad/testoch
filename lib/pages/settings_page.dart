import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CORTOBA/pages/login_page.dart';
import 'package:CORTOBA/pages/about_page.dart';
import 'package:CORTOBA/pages/user_page.dart';
import 'package:CORTOBA/pages/settings_page.dart';
import 'package:CORTOBA/pages/home_page copy.dart';
import 'package:CORTOBA/pages/change_password_page.dart';
import 'package:CORTOBA/pages/help_support_page.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String username = 'Admin';
  String role = 'User';
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    bool? isAdmin = prefs.getBool('isAdmin');

    setState(() {
      username = storedUsername ?? 'User';
      role = 'Admin';
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 0, 61, 104),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),

              ),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/app_icon/icon.png'), // Replace with your profile image
                  radius: 30,
                  
                ),
                title: Text(username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(role),
                
              ),
            ),
            SizedBox(height: 20),
            // Settings Options
            SettingsOption(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
            SettingsOption(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // Navigate to Notifications Settings
              },
            ),
            SettingsOption(
              icon: Icons.palette,
              title: 'Theme',
              onTap: () {
                // Navigate to Theme Settings
              },
            ),
            SettingsOption(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {
Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpSupportPage()),
                );              },
            ),
            SettingsOption(
              icon: Icons.info,
              title: 'About',
              onTap: () {
                // Navigate to About Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            // Optional: Logout Option
            SettingsOption(
              icon: Icons.logout,
              title: 'Logout',
              onTap: _logout,
            ),
            // Optional: Conditional Admin Panel
            if (role == 'Admin') ...[
              SettingsOption(
                icon: Icons.admin_panel_settings,
                title: 'Admin Panel',
                onTap: () {
                  // Navigate to Admin Panel
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          if (index == 3) {
            _showLogoutDialog();
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyUserPage()),
            );
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage1()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
        });
      },
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      selectedItemColor: const Color.fromARGB(255, 49, 136, 163),
      unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      type: BottomNavigationBarType.fixed,
      items: const [
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
          label: 'Setting',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.exit_to_app),
          label: 'Logout',
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: _logout,
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SettingsOption({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
} 