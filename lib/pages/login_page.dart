import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CORTOBA/pages/UserInput.dart';
import 'package:CORTOBA/pages/home_page.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signUserIn(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final username = usernameController.text;
    final password = passwordController.text;

    // API endpoint URL
    final url = Uri.parse('https://sculpin-improved-lizard.ngrok-free.app/api/login');

    try {
      // Prepare JSON data
      final bodyData = {
        'username': username,
        'password': password,
      };

      // Make POST request with JSON body
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          print('Response: ${response.body}');

          // Check if 'status' key exists and is not null
          if (jsonResponse['status'] == 'success') {
            // Check if 'token' key exists and is not null
            final token = jsonResponse['cookie'] as String?;
            if (token != null) {
              // Store JWT using shared_preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('cookie', token);
                     bool isAdmin = jsonResponse['is_admin'] == 1;
              // Navigate to home page or user input page based on role
              if (isAdmin) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserInp()),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Token not found in response'), duration: Duration(seconds: 5)),
              );
            }
          } else {
            // Check if 'message' key exists and is not null
            final errorMessage = jsonResponse['message'] as String? ?? 'Unknown error occurred';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 5)),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to parse response'), duration: Duration(seconds: 5)),
          );
          print('Error parsing JSON: $e');
        }
      } else {
        // Handle non-200 responses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${response.statusCode}: ${response.reasonPhrase}'), duration: const Duration(seconds: 5)),
        );
        print('Response status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e'), duration: const Duration(seconds: 5)),
      );
      print('Network error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.lock_open, size: 100, color: Colors.black),
                const SizedBox(height: 50),
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                ),
                const SizedBox(height: 25),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => signUserIn(context),
                        child: const Text('Sign In'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}