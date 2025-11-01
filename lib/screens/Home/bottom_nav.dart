import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/utils/route_transitions.dart';
import 'gemini_chat_screen.dart';

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..style = PaintingStyle.fill;

    // Top edge path for shadow
    final topEdge = Path();
    topEdge.moveTo(0, 20);
    topEdge.quadraticBezierTo(0, 0, 20, 0);
    topEdge.lineTo(size.width * 0.5 - 60, 0);
    topEdge.cubicTo(
      size.width * 0.5 - 40, 0,
      size.width * 0.5 - 40, 28,
      size.width * 0.5, 28
    );
    topEdge.cubicTo(
      size.width * 0.5 + 40, 28,
      size.width * 0.5 + 40, 0,
      size.width * 0.5 + 60, 0
    );
    topEdge.lineTo(size.width - 20, 0);
    topEdge.quadraticBezierTo(size.width, 0, size.width, 20);

    // Draw shadow above the bar, hugging the curve
    canvas.save();
    canvas.translate(0, -8); 
    canvas.drawShadow(
      topEdge,
      const Color.fromARGB(255, 255, 255, 255),
      18,
      true,
    );
    canvas.restore();

    // Full bar path
    final path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    path.lineTo(size.width * 0.5 - 60, 0);
    path.cubicTo(
      size.width * 0.5 - 40, 0,
      size.width * 0.5 - 40, 28,
      size.width * 0.5, 28
    );
    path.cubicTo(
      size.width * 0.5 + 40, 28,
      size.width * 0.5 + 40, 0,
      size.width * 0.5 + 60, 0
    );
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: SizedBox(
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main bottom bar with notch
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 80),
              painter: BottomNavPainter(),
            ),
            // Bottom navigation items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem("assets/icons/dashboard.svg", "Dashboard", 0),
                  _navItem("assets/icons/profile.svg", "Conveyors", 1),
                  const SizedBox(width: 80), // Space for FAB
                  _navItem("assets/icons/health.svg", "Notifications", 3),
                  _navItem("assets/icons/menu.svg", "Menu", 4),
                ],
              ),
            ),
            // Floating Fire Button (red circle, white SVG in middle)
            Positioned(
              top: -48, // Sits just above the curve
              left: MediaQuery.of(context).size.width / 2 - 32,
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53E3E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(140, 255, 255, 255),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/FAB.svg',
                      width: 36,
                      height: 36,
                      colorFilter: const ColorFilter.mode(
                        Color.fromARGB(255, 255, 255, 255),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String iconAsset, String label, int index) {
    final bool isSelected = currentIndex == index;
    final Color selectedColor = const Color(0xFF18D8FF);
    final Color unselectedColor = Colors.white70;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? selectedColor : unselectedColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              // Removed the indicator bar under the selected tab
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _showFireAlert() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fire Alert",
      barrierColor: Colors.black.withOpacity(0.2),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0)),
            ),
            Center(
              child: Container(
                width: 270,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Fire Really Catches?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF18D8FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Yes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF18D8FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "No",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Content for tab $_currentIndex',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Middle FAB -> open Gemini chat insights page
            Navigator.push(context, fadeRoute(const GeminiChatScreen()));
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      extendBody: true,
    );
  }
}