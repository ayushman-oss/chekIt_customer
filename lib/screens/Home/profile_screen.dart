import 'dart:developer';
import 'service_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_nav.dart';
import 'dashboard.dart';
import 'menu_screen.dart';
import '/utils/route_transitions.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int currentIndex;
  const ProfileScreen({super.key, this.currentIndex = 1});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pushReplacement(context, fadeRoute(const DashboardScreen())),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  const Text(
                    "Profile",
                    style: TextStyle(
                      color: Color.fromARGB(255, 197, 197, 197),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        fadeRoute(EditProfileScreen(
                          fullName: "Colin",
                          email: "colin@gmail.com",
                          mobile: "+1 415 555 2671",
                          location: "123 Main St, Austin, TX 78701",
                          area: "2000 Sqft",
                        )),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  _profileField("Full Name", "\nColin"),
                  const SizedBox(height: 28),
                  _profileField("Email Address", "\ncolin@gmail.com"),
                  const SizedBox(height: 28),
                  _profileField("Mobile Number", "\n+1 415 555 2671"),
                  const SizedBox(height: 28),
                  _profileField("Property Location", "\n123 Main St, Austin, TX 78701"),
                  const SizedBox(height: 26),
                  // Static image instead of map
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/image 34.png',
                      height: 220,
                      width: screenWidth - 40, // 20 padding on each side
                      fit: BoxFit.cover,
                    ),
                  ),
                  // --- Google Static Map commented out ---
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(14),
                  //   child: Image.network(
                  //     getStaticMapUrl(latitude, longitude),
                  //     height: 120,
                  //     width: double.infinity,
                  //     fit: BoxFit.cover,
                  //     loadingBuilder: (context, child, progress) =>
                  //         progress == null
                  //             ? child
                  //             : Container(
                  //                 height: 120,
                  //                 color: Colors.black12,
                  //                 child: const Center(
                  //                   child: CircularProgressIndicator(),
                  //                 ),
                  //               ),
                  //   ),
                  // ),
                  const SizedBox(height: 28),
                  _profileField("Property Area", "2000 Sqft"),
                  const SizedBox(height: 40), // Extra space at bottom
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          if (index == 0) {
            Navigator.pushReplacement(context, fadeRoute(const DashboardScreen()));
          } else if (index == 4) {
            Navigator.pushReplacement(context, fadeRoute(const MenuScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, fadeRoute(const Service()));
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
      extendBody: true,
    );
  }

  Widget _profileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color:Color.fromARGB(255, 197, 197, 197),
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF6B6B6B),
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}