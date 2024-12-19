import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Button Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UsMyButton(),
    );
  }
}

class UsMyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Button Example')),
      body: Center(
        child: MyButton(
          onTap: () {
            // Handle button tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Button tapped!')),
            );
          },
          text: 'Sign In',
          color: Colors.blue,
          borderRadius: 20.0,
          width: 200, // Set desired width
          height: 60, // Set desired height
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final Color color;
  final double borderRadius;
  final double width; // New property for button width
  final double height; // New property for button height

  const MyButton({
    Key? key,
    required this.onTap,
    this.text = 'Sign In', // Default text
    this.color = Colors.blue, // Default color
    this.borderRadius = 12.0, // Default border radius
    this.width = 300, // Default width
    this.height = 60, // Default height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius), // For ripple effect
        child: Container(
          width: width, // Use the width property
          height: height, // Use the height property
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
