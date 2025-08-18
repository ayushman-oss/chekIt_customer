import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const stepTypes = {
  "alert": {
    "icon": "assets/icons/Alert.svg",
    "label": "Alert Initiated",
    "color":const Color.fromARGB(255, 23, 199, 0),
  },
  "accepted": {
    "icon": "assets/icons/Tick.svg",
    "label": "Accepted",
    "color": const Color.fromARGB(255, 23, 199, 0),
  },
  "driver": {
    "icon": "assets/icons/Delivery.svg",
    "label": "Driver Arrived",
    "color": const Color.fromARGB(255, 23, 199, 0),
  },
  "sprayed": {
    "icon": "assets/icons/Service.svg",
    "label": "Sprayed",
    "color": const Color.fromARGB(255, 23, 199, 0),
  },
};

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  int? expandedIndex;

  final history = [
    {
      "amount": "\$500",
      "area": "1000 Sqft",
      "date": "July 20, 2025",
      "status": "Closed",
      "steps": [
        {"type": "alert", "time": "11:25 AM"},
        {"type": "accepted", "time": "11:26 AM"},
        {"type": "driver", "time": "11:31 AM"},
        {"type": "sprayed", "time": "11:35 AM"},
      ]
    },
    {
      "amount": "\$1000",
      "area": "2000 Sqft",
      "date": "June 30, 2025",
      "status": "Closed",
      "steps": [
        {
          "type": "alert",
          "time": "09:00 AM",
        },
        {
          "type": "accepted",
          "time": "09:05 AM",
        },
        {
          "type": "driver",
          "time": "09:10 AM",
        },
        {
          "type": "sprayed",
          "time": "09:15 AM",
        },
      ],
    },
    {
      "amount": "\$750",
      "area": "1500 Sqft",
      "date": "August 10, 2025",
      "status": "Closed",
      "steps": [
        {
          "type": "alert",
          "time": "10:00 AM",
        },
        {
          "type": "accepted",
          "time": "10:05 AM",
        },
        {
          "type": "driver",
          "time": "10:10 AM",
        },
        {
          "type": "sprayed",
          "time": "10:15 AM",
        },
      ]
    }
  ];

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
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  const Text(
                    "Service History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 28), // For symmetry
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 12),
                    Icon(Icons.search, color: Color(0xFF18D8FF), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Search",
                        style: TextStyle(
                          color: Color(0xFF18D8FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                itemCount: history.length,
                itemBuilder: (context, idx) {
                  final item = history[idx];
                  final isExpanded = expandedIndex == idx;
                  final steps = item["steps"] as List;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF292929),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row
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
                              const SizedBox(width: 12),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  item["area"] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item["date"] as String,
                                    style: const TextStyle(
                                      color: Color(0xFFB0B0B0),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        expandedIndex = isExpanded ? null : idx;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          item["status"] as String,
                                          style: const TextStyle(
                                            color: Color(0xFF1DEB4B),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: const Color(0xFF1DEB4B),
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Steps Timeline
                          if (isExpanded && steps.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 70,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Timeline line (centered with icons)
                                  Positioned(
                                    left: 28, 
                                    right: 14,
                                    top: 28/2.4, 
                                    child: Container(
                                      height: 4,
                                      color: const Color.fromARGB(255, 23, 199, 0),
                                    ),
                                  ),
                                  // Steps
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: steps.map<Widget>((step) {
                                      final s = step as Map;
                                      final type = stepTypes[s["type"]];
                                      return Column(
                                        children: [
                                          // SVG Icon with colored border, neutral fill
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF232323),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: type?["color"] as Color,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                type?["icon"] as String,
                                                width: 28,
                                                height: 28,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            type?["label"] as String,
                                            style: TextStyle(
                                              color: type?["color"] as Color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            s["time"] as String,
                                            style: const TextStyle(
                                              color: Color(0xFFB0B0B0),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
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