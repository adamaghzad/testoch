import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'login_page.dart'; // Import the login page for navigation

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> signUserUp(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;


    // API endpoint URL for sign-up
    final url = Uri.parse(
        'https://sculpin-improved-lizard.ngrok-free.app/api/signup');

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
          // Navigate to the login page after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          // Show error message for registration failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        // Handle non-200 responses from the server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error: Registration failed',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: Duration(seconds: 3),
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
                const Icon(Icons.person_add, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Create a new account',
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

                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                MyButton(onTap: () => signUserUp(context)),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () {
                    // Navigate to the login page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}