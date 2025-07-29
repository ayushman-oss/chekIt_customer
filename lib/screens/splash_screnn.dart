import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image aligned to the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/splash_screen.png',
              width: screenWidth,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top logo
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Image.asset(
                  'assets/images/logo.png', // Placeholder
                  width: 200, // Adjust size as needed
                ),
              ),
              // Bottom text (Powered By)
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Text(
                  'Powered By CHEKIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
