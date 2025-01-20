import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar with a Gradient Background
      appBar: AppBar(
        title: Text('About'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
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
              // App Logo or Icon
              Center(
                child: Icon(
                  Icons.info,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              // App Name
              Center(
                child: Text(
                  'CORTOBA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Version Information
              Center(
                child: Text(
                  'Version: 1.0.0',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 30),
              // Description
              Text(
                'CORTOBA is a Flutter-based mobile application designed to provide users with an intuitive and seamless experience. It allows users to manage their profiles, change settings, and access various features tailored to their roles.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // Developer Information
              Text(
                'Developed by:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'AGENCY (AGENCY adamaghzaf && ayoubaitameur)',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // Contact Information
              Text(
                'Contact Us:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'Email: support@cortoba.com',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
              SizedBox(height: 5),
              Text(
                'Website: www.cortoba.com',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
              // Add more sections as needed
            ],
          ),
        ),
      ),
    );
  }
} 