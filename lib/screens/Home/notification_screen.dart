import 'package:flutter/material.dart';
import '/utils/route_transitions.dart';
import 'menu_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "type": "alert",
        "title": "Heavy Rain Alert",
        "desc": "Severe rainfall expected within 24 hrs. Possible flooding in low-lying areas. Travel only if necessary.",
        "date": "16 May",
        "color": Colors.red,
      },
      {
        "type": "alert",
        "title": "Emergency Fire Status – Initiated",
        "desc": "Fire emergency initiated. Response team dispatched. Follow safety instructions and remain alert.",
        "date": "25 Apr",
        "color": Colors.red,
      },
      {
        "type": "info",
        "title": "Home Sprayed",
        "desc": "The scheduled spraying has been completed. Please avoid the treated area for the next few hours as advised.",
        "date": "2 Mar",
        "color": Colors.green,
      },
      {
        "type": "info",
        "title": "Driver Arrived",
        "desc": "Our technician is on-site now.",
        "date": "15 Feb",
        "color": Colors.purple,
      },
      {
        "type": "info",
        "title": "Service Request Received",
        "desc": "We’ve received your request and will update you soon.We’ve received your request and will update you soon.We’ve received your request and will update you soon.We’ve received your request and will update you soon.",
        "date": "2 Mar",
        "color": Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Uniform Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      fadeRoute(const MenuScreen()),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Notifications",
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
            const SizedBox(height: 18),
            // Notification List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 0),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withOpacity(0.08),
                  height: 0,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return Dismissible(
                    key: ValueKey((n["title"] as String) + (n["date"] as String)),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: const Color(0xFFE53E3E),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 32),
                      child: const Icon(Icons.delete, color: Colors.white, size: 36),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: n["type"] == "alert"
                            ? const Color(0xFF3B2323)
                            : n["title"] == "Home Sprayed"
                                ? const Color(0xFF233023)
                                : Colors.transparent,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6, right: 10),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: n["color"] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n["title"] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n["desc"] as String,
                                      style: const TextStyle(
                                        color: Color(0xFFB0B0B0),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Text(
                              n["date"] as String,
                              style: const TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}