import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:CORTOBA/pages/UserInput.dart';
import 'package:CORTOBA/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/my_button.dart';
import 'components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUserIn(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    // API endpoint URL
    final url = Uri.parse(
        'https://c6eb-41-251-81-69.ngrok-free.app/testoch/login.php');

    try {
      // Make POST request to the backend
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
       
        // Parse response from the backend
        final jsonResponse = jsonDecode(response.body);
        print('Response: ${response.body}'); // Log response for debugging

        if (jsonResponse['status'] == 'success') {
          // Store cookies and CSRF token using SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('cookie', jsonResponse['cookie']);

          // Check if the user is an admin
          bool isAdmin = jsonResponse['is_admin'] == 1;

          // Navigate based on the user's role
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage()), // Admin home page
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UserInp()), // User input page
            );
          }
        } else {
          // Show error message for invalid credentials
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        // Handle non-200 responses from the server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red, // Change background color for error
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white), // Add error icon
                SizedBox(width: 8), // Space between icon and text
                Expanded(
                  child: Text(
                    'Error: invalid Username or Password', // Show status code
                    style: TextStyle(color: Colors.white), // Change text color
                  ),
                ),
              ],
            ),
            duration: Duration(seconds: 3), // Duration for how long it shows
          ),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                MyButton(onTap: () => signUserIn(context)),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
