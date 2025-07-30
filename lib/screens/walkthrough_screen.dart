import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; 

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({Key? key}) : super(key: key);

  @override
  _WalkthroughScreenState createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> walkthroughData = [
    {
      'image': 'assets/images/luke-flynt-9jErXqFwAYs-unsplash 2.png',
      'text': 'PROACTIVE WILDFIRE HOME PROTECTION CHECKiT GEL - COATS YOUR HOME BEFORE THE FIRE HITS',
      'buttonText': 'SUBSCRIBE',
      'bottomText': 'AS A SUBSCRIBER YOU GET 48 Hr Guaranteed Response'
    },
    {
      'image': 'assets/images/luke-flynt-9jErXqFwAYs-unsplash 2 (1).png',
      'text': 'ANOTHER WILDFIRE PROTECTION MESSAGE MORE DETAILS ABOUT THE SERVICE',
      'buttonText': 'GET STARTED',
      'bottomText': 'Learn more about our plans'
    },
     {
      'image': 'assets/images/luke-flynt-9jErXqFwAYs-unsplash 2 (2).png',
      'text': 'FINAL WILDFIRE PROTECTION SCREEN READY TO PROTECT YOUR HOME',
      'buttonText': 'FINISH',
      'bottomText': ''
    },
    // Add more walkthrough pages here
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: walkthroughData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return WalkthroughPage(
                imagePath: walkthroughData[index]['image']!,
                text: walkthroughData[index]['text']!,
                buttonText: walkthroughData[index]['buttonText']!,
                 bottomText: walkthroughData[index]['bottomText']!,
              );
            },
          ),
          Positioned(
            bottom: 50, // Adjust position as needed
            left: 0,
            right: 0,
            child: Column(
              children: [
                 if (walkthroughData[_currentPage]['bottomText']!.isNotEmpty) 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), // Space between button and bottom text
                    child: Text(
                      walkthroughData[_currentPage]['bottomText']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto( // Use GoogleFonts
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    walkthroughData.length,
                    (index) => buildDot(index: index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 10,
      width: _currentPage == index ? 30 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF00FFFF) : Colors.white, // Use cyan for active dot, white for inactive
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class WalkthroughPage extends StatelessWidget {
  final String imagePath;
  final String text;
  final String buttonText;
   final String bottomText;

  const WalkthroughPage({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.buttonText,
    required this.bottomText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
        Container(
          // Optional: Add an overlay to the image for better text readability
          color: Colors.black.withOpacity(0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(), // Push content to center-bottom
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 28, // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.5,
                ), // Updated styling
              ),
              const SizedBox(height: 30), // Increased spacing
              // Button with updated styling based on Figma
              ElevatedButton(
                onPressed: () {
                  // Button action - will implement later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6200), // Button color - Orange
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0), // Button padding and horizontal padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Button border radius
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Button text color
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space between button and bottom text
             
               const Spacer(flex: 2), // Push content further down
            ],
          ),
        ),
      ],
    );
  }
}
