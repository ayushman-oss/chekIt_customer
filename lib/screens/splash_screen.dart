import 'package:flutter/material.dart';
import 'walkthrough_screen.dart'; // Import the walkthrough screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWalkthrough();
  }

  _navigateToWalkthrough() async {
    await Future.delayed(const Duration(milliseconds: 3000)); // Adjust delay as needed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const WalkthroughScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: -screenHeight*0.24,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_screen.png', 
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.fitWidth,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start, 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.15), 
                child: Image.asset(
                  'assets/images/logo.png', 
                  width: screenWidth * 0.5, 
                  fit: BoxFit.contain,
                ),
              ),
              ],
          ),

          
          Positioned(
            bottom: 50.0, // Adjust bottom padding as needed
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Keep the row size minimal
                children: [
                  Text(
                    'Powered By ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo.png', 
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
