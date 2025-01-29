import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HelpSupportPage extends StatefulWidget {
  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _problemController = TextEditingController();
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Replace with your actual API endpoint
  final String _submitUrl = 'https://sculpin-improved-lizard.ngrok-free.app/api/support/request';

  // Initialize cookie-related variables
  bool _isCookieSaved = false;
  String? _cookie;

  @override
  void initState() {
    super.initState();
    _checkCookie();
  }

  // Fetch the cookie from SharedPreferences
  Future<void> _checkCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookie = prefs.getString('cookie'); // Retrieve the stored cookie
    setState(() {
      _isCookieSaved = cookie != null;
      _cookie = cookie;
    });

    // Print the cookie value to the console
    if (cookie != null) {
      print('Saved Cookie: $cookie');
    } else {
      print('No cookie saved.');
    }
  }

  Future<void> _submitProblem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    String problemDescription = _problemController.text;

    try {
      final response = await http.post(
        Uri.parse(_submitUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_cookie != null) 'Cookie': 'user_auth=$_cookie;',
        },
        body: jsonEncode({
          'message': problemDescription,
        }),
      );

      // Optionally handle cookies from the response
      _saveCookieFromResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Submission successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your problem has been submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _problemController.clear();
      } else {
        // Handle server errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Save the cookie from the response headers
  void _saveCookieFromResponse(http.Response response) async {
    String? receivedCookie = response.headers['set-cookie'];
    if (receivedCookie != null) {
      // Extract the cookie value if necessary
      // This example assumes the entire 'set-cookie' header is the cookie value
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('cookie', receivedCookie);
      setState(() {
        _cookie = receivedCookie;
        _isCookieSaved = true;
      });
      print('Updated Cookie: $receivedCookie');
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with gradient background
      appBar: AppBar(
        title: Text('Help & Support'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQs Section
              Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ExpansionTile(
                  leading: Icon(Icons.question_answer, color: Colors.blue),
                  title: Text('How to reset my password?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'To reset your password, go to Settings > Change Password and follow the instructions.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ExpansionTile(
                  leading: Icon(Icons.contact_support, color: Colors.blue),
                  title: Text('How to contact support?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'You can contact support by emailing support@cortoba.com or calling 123-456-7890.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // Contact Information Section
              Text(
                'Contact Us',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Card(
                color: Colors.blue.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.email, color: Colors.blue),
                  title: Text('Email: support@cortoba.com', style: TextStyle(fontSize: 16)),
                ),
              ),
              Card(
                color: Colors.blue.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.phone, color: Colors.blue),
                  title: Text('Phone: (+212)614-192-699', style: TextStyle(fontSize: 16)),
                ),
              ),
              Card(
                color: Colors.blue.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.blue),
                  title: Text('Address: 122 Emsi Rodani Casablanca Maarif, Maroc', style: TextStyle(fontSize: 16)),
                ),
              ),
              
              Divider(height: 40, thickness: 2),

              // Problem Submission Form
              Text(
                'Describe Your Problem',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Problem Description Field
                    TextFormField(
                      controller: _problemController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.edit, color: Colors.blue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: 'Problem Description',
                        hintText: 'Describe your issue here...',
                        filled: true,
                        fillColor: Colors.blue.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe your problem.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitProblem,
                        icon: Icon(Icons.send, color: Colors.white),
                        label: Text(
                          _isSubmitting ? 'Submitting...' : 'Submit',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}