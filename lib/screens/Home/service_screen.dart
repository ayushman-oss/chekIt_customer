import 'package:flutter/material.dart';
import 'bottom_nav.dart';
import 'dashboard.dart';
import 'profile_screen.dart';
import 'menu_screen.dart';
import '/utils/route_transitions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Service extends StatefulWidget {
  final int currentIndex;
  const Service({super.key, this.currentIndex = 2});

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  // Step type map for DRY timeline
  static const stepTypes = {
    "alert": {
      "icon": "assets/icons/Alert.svg",
      "label": "Alert Initiated",
      "color": Color(0xFFFF1744),
    },
    "accepted": {
      "icon": "assets/icons/Tick.svg",
      "label": "Accepted",
      "color": Color(0xFFFFB300),
    },
    "driver": {
      "icon": "assets/icons/Delivery.svg",
      "label": "Driver Arrived",
      "color": Color(0xFFB620E0),
    },
    "sprayed": {
      "icon": "assets/icons/Service.svg",
      "label": "Sprayed",
      "color": Color(0xFF1DE9B6),
    },
  };

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final services = [
      {
        "amount": "\$500",
        "area": "1000 Sqft",
        "date": "July 20, 2025",
        "status": "Sprayed",
        "percent": 50.0, // Try 100.0, 75.0, etc.
        "steps": [
          {"type": "alert", "time": "11:25 AM"},
          {"type": "accepted", "time": "11:26 AM"},
          {"type": "driver", "time": "11:31 AM"},
          {"type": "sprayed", "time": "11:35 AM"},
        ]
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      fadeRoute(const DashboardScreen()),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Services",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, idx) {
                  final item = services[idx];
                  final steps = item["steps"] as List;
                  final percent = item["percent"] as double;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 32), // More padding under each card
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Amount and Date
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["amount"] as String,
                              style: const TextStyle(
                                color: Color(0xFF18D8FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item["date"] as String,
                              style: const TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Area and Status Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item["area"] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item["status"] as String,
                              style: const TextStyle(
                                color: Color(0xFF18D8FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Timeline
                        _ServiceTimeline(
                          steps: List<Map<String, dynamic>>.from(steps),
                          percent: percent,
                          stepTypes: stepTypes,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == _currentIndex) return;
          if (index == 0) {
            Navigator.pushReplacement(context, fadeRoute(const DashboardScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, fadeRoute(const ProfileScreen()));
          } else if (index == 4) {
            Navigator.pushReplacement(context, fadeRoute(const MenuScreen()));
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

class _ServiceTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  final double percent; // 0-100
  final Map<String, Map<String, dynamic>> stepTypes;

  const _ServiceTimeline({
    required this.steps,
    required this.percent,
    required this.stepTypes,
  });

  @override
  Widget build(BuildContext context) {
    final int total = steps.length;
    // Discrete: round percent to nearest step
    final int completed = ((percent / 100) * total).round().clamp(0, total);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final stepWidth = total > 1 ? (availableWidth - 60) / (total - 1) : 0;
        
        return SizedBox(
          height: 90,
          child: Stack(
            children: [
              // Timeline background line (gray)
              Positioned(
                left: 30,
                right: 30,
                top: 15, // Center with icon centers
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB0B0B0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Timeline progress line (green, calculated based on completion)
              if (completed > 0 && total > 1)
                Positioned(
                  left: 30,
                  top: 15,
                  child: Container(
                    width: stepWidth * (completed - 1).toDouble(),
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 23, 199, 0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              // Steps positioned with proper spacing
              ...List.generate(total, (i) {
                final s = steps[i];
                final type = stepTypes[s["type"]];
                final isDone = i < completed;
                final isCurrent = i == completed - 1;
                final color = (isDone || isCurrent) && type != null
                    ? type["color"] as Color
                    : const Color(0xFFB0B0B0);

                return Positioned(
                  left: i.toDouble() * stepWidth,
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: type != null
                              ? SvgPicture.asset(
                                  type["icon"] as String,
                                  width: 18,
                                  height: 18,
                                )
                              : const SizedBox(width: 18, height: 18),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 70, // Fixed width for consistent layout
                        child: Text(
                          type != null ? type["label"] as String : "",
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s["time"] as String,
                        style: const TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }
    );
  }
}