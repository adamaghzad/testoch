import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HelpSupportPage extends StatefulWidget {
  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _problemController = TextEditingController();
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Replace with your actual API endpoint
  final String _submitUrl = 'https://sculpin-improved-lizard.ngrok-free.app/api/support/submit';

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
        },
        body: jsonEncode({
          'description': problemDescription,
          
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Submission successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your problem has been submitted successfully!')),
        );
        _problemController.clear();
      } else {
        // Handle server errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit. Please try again later.')),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
      appBar: AppBar(
        title: Text('Help & Support'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Frequently Asked Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ExpansionTile(
                title: Text('How to reset my password?'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        'To reset your password, go to Settings > Change Password and follow the instructions.'),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('How to contact support?'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        'You can contact support by emailing support@example.com or calling 123-456-7890.'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Contact Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Email: support@cortoba.com',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text('Phone: (123-456-7890)', style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text('Address: 123 Flutter Street, Dart City',
                  style: TextStyle(fontSize: 16)),
              
              Divider(height: 40, thickness: 2),
              
              Text('Describe Your Problem',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _problemController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Problem Description',
                        hintText: 'Describe your issue here...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe your problem.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _isSubmitting
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitProblem,
                            child: Text('Submit'),
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