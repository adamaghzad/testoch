import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'components/my_button.dart';
import 'components/my_textfield.dart';
import 'signup_page.dart'; // Import the sign-up page for navigation
import 'home_page copy.dart'; // Import the home page after successful login

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> signUserIn(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // API endpoint URL for login
    final url = Uri.parse(
        'https://sculpin-improved-lizard.ngrok-free.app/api/login');

    try {
      // Make POST request to the backend
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );


      if (response.statusCode == 200) {
        // Parse response from the backend
        final jsonResponse = jsonDecode(response.body);
        print('Response: ${response.body}'); // Log response for debugging

        if (jsonResponse['status'] == 'success') {
          // Save username and isAdmin to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setBool('isAdmin', jsonResponse['isAdmin'] ?? false);
          // Store cookies and CSRF token using SharedPreferences
         
          await prefs.setString('cookie', jsonResponse['cookie']);


          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Login successful! Redirecting to home.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to the home page after a short delay
          await Future.delayed(Duration(seconds: 3));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage1()),
          );
        } else {
          // Show error message for login failure
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
                    'Error: Login failed',
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Icon(
          Icons.login,
          size: 100,
          color: Colors.black,
        ),
        SizedBox(height: 20),
        Text(
          'CORTOBA',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      'Welcome Back!\nLogin to your account',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    SizedBox(height: 20),
                    _buildWelcomeText(),
                    SizedBox(height: 30),
                    MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                      prefixIcon: Icons.person,
                    ),
                    
                    SizedBox(height: 20),
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      prefixIcon: Icons.lock,
                    ),
                    SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator()
                        : MyButton(
                            onTap: () => signUserIn(context),
                            text: 'Login',
                            color: Colors.blue.shade700,
                            borderRadius: 12.0,
                            width: double.infinity,
                            height: 50,
                          ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Navigate to the sign-up page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
