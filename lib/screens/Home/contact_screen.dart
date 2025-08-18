import 'package:flutter/material.dart';
import '../../utils/route_transitions.dart';
import 'menu_screen.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                    "Contact",
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _ContactCard(
                    icon: Icons.location_on,
                    text: "Los Angeles Office",
                  ),
                  const SizedBox(height: 18),
                  _ContactCard(
                    icon: Icons.phone,
                    text: "(123) 456-7890",
                  ),
                  const SizedBox(height: 18),
                  _ContactCard(
                    icon: Icons.mail,
                    text: "Info@Chekit.com",
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialIcon(icon: Icons.facebook, onTap: () {}),
                      const SizedBox(width: 24),
                      _SocialIcon(icon: Icons.camera_alt_rounded, onTap: () {}), // Use Instagram icon if you have SVG
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Copyright CHEKiT, INC. 2025. ALL RIGHTS RESERVED.",
                    style: TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color:const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
            blurRadius: 1,
            offset: const Offset(0, 0),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}