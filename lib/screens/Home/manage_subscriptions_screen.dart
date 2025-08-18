import 'package:flutter/material.dart';
import '../../utils/route_transitions.dart ';
import 'menu_screen.dart';

class ManageSubscriptionsScreen extends StatelessWidget {
  const ManageSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pushReplacement(context, fadeRoute(const MenuScreen())),
                  ),
                  const Spacer(),
                  const Text(
                    "Manage Subscriptions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Current Plan
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Current Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: Color(0xFF7ED957),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monthly \$199",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Initiation Fee one-time \$299",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            // Other Plan
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Other Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: Color(0xFF7ED9FF),
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                child: const Text(
                  "Annual ONE time payment\n\$1,999",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Terms & Conditions
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: TextStyle(
                          color: Color(0xFF18D8FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      TextSpan(
                        text: " and ",
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontWeight: FontWeight.w400,
                          fontSize: 17,
                        ),
                      ),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: Color(0xFF18D8FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}