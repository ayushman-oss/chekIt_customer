import 'package:flutter/material.dart';
import '/utils/route_transitions.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';
import 'bottom_nav.dart';
import 'service_history_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
  "type": "alert",
  "title": "Conveyor Belt Breakdown – CV-102",
  "desc": "Major belt tear detected on CV-102 near Transfer Tower T3. Material flow of bauxite from Mines Yard to Crusher Unit halted. Maintenance team dispatched for inspection and belt jointing.",
  "date": "16 May",
  "color": Colors.red,
},
{
  "type": "alert",
  "title": "Motor Overload Trip – CV-210",
  "desc": "Drive motor overload trip on CV-210. Alumina transfer from Calcination Section to Storage Silos temporarily stopped. Electrical and mechanical teams notified for fault analysis.",
  "date": "25 Apr",
  "color": Colors.red,
},
{
  "type": "info",
  "title": "Conveyor Belt CV-105 Serviced",
  "desc": "Routine maintenance and roller replacement completed on CV-105. Material transfer of crushed bauxite from Crusher House to Pre-blending Yard resumed.",
  "date": "2 Mar",
  "color": Colors.green,
},
{
  "type": "info",
  "title": "Lubrication Completed – CV-301 Drive Unit",
  "desc": "Drive pulley and gear unit lubrication completed at CV-301. This belt carries alumina from Storage Silo to Loading Conveyor. System running normally.",
  "date": "15 Feb",
  "color": Colors.purple,
},
{
  "type": "info",
  "title": "Maintenance Request Logged – CV-220",
  "desc": "A service request has been raised for CV-220 due to abnormal belt noise during alumina transfer from Refinery Unit to Packing Section. Awaiting scheduling confirmation.",
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
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          if (index == 1) {
            Navigator.pushReplacement(context, fadeRoute(const ServiceHistoryScreen()));
          } else if (index == 4) {
            Navigator.pushReplacement(context, fadeRoute(const MenuScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, fadeRoute(const NotificationScreen()));
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}