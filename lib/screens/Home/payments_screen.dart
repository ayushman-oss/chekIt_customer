import 'package:flutter/material.dart';
import '../../utils/route_transitions.dart';
import 'menu_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int? expandedIndex;

  final List<Map<String, dynamic>> payments = [
    {
      "sqft": "1000",
      "expectedDue": "\$500",
      "fireStatus": "Emergency Initiated",
      "fireStatusColor": const Color(0xFFFFB300), // Orange/Yellow
      "paymentStatus": "Pending",
      "paymentStatusColor": const Color(0xFFFF4444), // Red
      "date": "July 20, 2025",
      "time": "10:32 AM",
      "isPaid": false,
    },
    {
      "sqft": "2000",
      "expectedDue": "\$1000",
      "fireStatus": "Closed",
      "fireStatusColor": const Color(0xFF7ED957), // Green
      "paymentStatus": "Paid",
      "paymentStatusColor": const Color(0xFF7ED957), // Green
      "date": "June 30, 2025",
      "time": "10:32 AM",
      "isPaid": true,
    },
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
                    onPressed: () => Navigator.pushReplacement(context, fadeRoute(const MenuScreen())),
                  ),
                  const Spacer(),
                  const Text(
                    "My Payments",
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
            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Color(0xFF18D8FF)),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF18D8FF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: payments.length,
                itemBuilder: (context, idx) {
                  final payment = payments[idx];
                  final isExpanded = expandedIndex == idx;
                  return PaymentCard(
                    sqft: payment["sqft"],
                    expectedDue: payment["expectedDue"],
                    fireStatus: payment["fireStatus"],
                    fireStatusColor: payment["fireStatusColor"],
                    paymentStatus: payment["paymentStatus"],
                    paymentStatusColor: payment["paymentStatusColor"],
                    date: payment["date"],
                    time: payment["time"],
                    isPaid: payment["isPaid"],
                    isExpanded: isExpanded,
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? null : idx;
                      });
                    },
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



class StatusCutoutClipper extends CustomClipper<Path> {
  final double cutoutWidth;
  final double cutoutHeight;
  final double cornerRadius;

  StatusCutoutClipper({
    this.cutoutWidth = 40,
    this.cutoutHeight = 24,
    this.cornerRadius = 8,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    // Main rectangle minus cutout
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - cutoutHeight);


    // Cutout shape (rounded rectangle)
    path.lineTo(size.width - cutoutWidth + cornerRadius, size.height - cutoutHeight);
    path.arcToPoint(
      Offset(size.width - cutoutWidth, size.height - cutoutHeight + cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );
    path.lineTo(size.width - cutoutWidth, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cutoutWidth - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Finish bottom edge
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


class PaymentCard extends StatelessWidget {
  final String sqft;
  final String expectedDue;
  final String fireStatus;
  final Color fireStatusColor;
  final String paymentStatus;
  final Color paymentStatusColor;
  final String date;
  final String time;
  final bool isPaid;
  final bool isExpanded;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.sqft,
    required this.expectedDue,
    required this.fireStatus,
    required this.fireStatusColor,
    required this.paymentStatus,
    required this.paymentStatusColor,
    required this.date,
    required this.time,
    required this.isPaid,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: isExpanded ? 16 : 32),
          child: ClipPath(
            clipper: StatusCutoutClipper(cutoutHeight: isExpanded ? 0 : 36 , cutoutWidth: isExpanded ? 0 : isPaid ? 66 : 90,cornerRadius: 18),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sqft: $sqft",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    color: Color(0xFFB0B0B0),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Expected Due: $expectedDue",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            text: "Fire Status: ",
                            style: const TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: fireStatus,
                                style: TextStyle(
                                  color: fireStatusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: "Payment Status: ",
                              style: const TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: paymentStatus,
                                  style: TextStyle(
                                    color: paymentStatusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPaid
                                    ? const Color(0xFF6B6B6B)
                                    : const Color(0xFF18D8FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: isPaid ? null : () {},
                              child: Text(
                                isPaid ? "Paid" : "Pay Now",
                                style: TextStyle(
                                  color: isPaid ? const Color(0xFFB0B0B0) : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        if (!isExpanded)
          Positioned(
            bottom: 32,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isPaid ? const Color(0xFF4CAF50) : const Color(0xFFFF4444),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isPaid ? "Paid" : "Pending",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
