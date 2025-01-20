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
  final double width;
  final double height;

  const MyButton({
    Key? key,
    required this.onTap,
    this.text = 'Sign In',
    this.color = Colors.blue,
    this.borderRadius = 12.0,
    this.width = 300,
    this.height = 60,
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
        borderRadius: BorderRadius.circular(borderRadius), // Ripple effect
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
