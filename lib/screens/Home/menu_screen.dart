import 'package:flutter/material.dart';
import 'bottom_nav.dart';
import 'dashboard.dart';
import 'profile_screen.dart';
import 'notification_screen.dart'; 
import 'service_history_screen.dart';
import 'service_screen.dart';
import 'family_screen.dart';
import 'contact_screen.dart';
import 'manage_subscriptions_screen.dart';
import 'payments_screen.dart';
import '/utils/route_transitions.dart';
import 'change_password_screen.dart';


class MenuScreen extends StatefulWidget {
  final int currentIndex;
  const MenuScreen({super.key, this.currentIndex = 4});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 4;
  int _selectedMenuIndex = -1;

  final List<String> menuItems = [
    "About Us",
    //"Manage Subscriptions",
    //"Service History",
    //"My Payments",
    //"Notifications",
    "Change Password",
    "Contact",
    //"Family Member",
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onMenuTap(int index) {
    setState(() {
      _selectedMenuIndex = index;
    });
    if (menuItems[index] == "Notifications") {
      Navigator.push(context, fadeRoute(const NotificationScreen()));
    } else if (menuItems[index] == "Service History") {
      Navigator.push(context, fadeRoute(const ServiceHistoryScreen()));
    } else if (menuItems[index] == "Family Member") {
      Navigator.push(context, fadeRoute(const FamilyScreen()));
    } else if (menuItems[index] == "Contact") {
      Navigator.push(context, fadeRoute(const ContactScreen()));
    } else if (menuItems[index] == "My Payments") {
      Navigator.push(context, fadeRoute(const PaymentsScreen()));
    } else if (menuItems[index] == "Change Password") {
      Navigator.push(context, fadeRoute(const ChangePasswordScreen()));
    } else if (menuItems[index] == "Manage Subscriptions") {
      Navigator.push(context, fadeRoute(const ManageSubscriptionsScreen()));
    }  
    else {
      Navigator.push(
        context,
        fadeRoute(
          Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                menuItems[index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
              child: Text(
                '${menuItems[index]} Page (Coming Soon)',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
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
                    "Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 28), 
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Menu Items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 26),
                itemBuilder: (context, index) {
                  final isSelected = _selectedMenuIndex == index;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      splashColor: Colors.white.withOpacity(0.06),
                      highlightColor: Colors.transparent,
                      onTap: () => _onMenuTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 49, 49, 49),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          title: Text(
                            menuItems[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color.fromARGB(255, 131, 131, 131),
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                          splashColor: Colors.transparent,
                          //highlightColor: Colors.transparent,
                          onTap: null, 
                        ),
                      ),
                    ),
                  );
                },
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
          } else if (index == 1) {
            Navigator.pushReplacement(context, fadeRoute(const ServiceHistoryScreen()));
          }  else if (index == 3) {
            Navigator.pushReplacement(context, fadeRoute(const NotificationScreen()));
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
}