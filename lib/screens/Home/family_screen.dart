import 'package:flutter/material.dart';
import 'add_family_screen.dart';
import '../../utils/route_transitions.dart';
import 'menu_screen.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final family = [
      {
        "name": "Michael Thompson",
        "email": "mike.t@inboxusa.net",
      },
      {
        "name": "Sarah Robinson",
        "email": "sarah.robinson@mailcentral.org",
      },
      {
        "name": "Sarah Robinson",
        "email": "sarah.robinson@mailcentral.org",
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
                    onPressed: () => Navigator.pushReplacement(context, fadeRoute(const MenuScreen())),
                  ),
                  const Spacer(),
                  const Text(
                    "Family Members",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 26),
                        onPressed: () {
                          Navigator.push(
                            context,
                            fadeRoute(const AddFamilyScreen()),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 26),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                itemCount: family.length,
                itemBuilder: (context, idx) {
                  final member = family[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: SwipeToDeleteCard(
                      key: ValueKey(member["email"]),
                      member: member,
                      onDelete: () {
                        print("Deleting ${member["name"]}");
                      },
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

class SwipeToDeleteCard extends StatefulWidget {
  final Map<String, String> member;
  final VoidCallback onDelete;

  const SwipeToDeleteCard({
    super.key,
    required this.member,
    required this.onDelete,
  });

  @override
  State<SwipeToDeleteCard> createState() => _SwipeToDeleteCardState();
}

class _SwipeToDeleteCardState extends State<SwipeToDeleteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0.0;
  bool _isDragging = false;
  double _screenWidth = 0.0;
  static const double _deleteThreshold = 80.0; 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final delta = details.primaryDelta ?? 0.0;
    final oldDragExtent = _dragExtent;
    
    if (delta < 0.0 || _dragExtent > 0.0) {
      _dragExtent = (_dragExtent - delta).clamp(0.0, _screenWidth);
    }

    if (oldDragExtent != _dragExtent) {
      setState(() {});
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;
    
    // If dragged past threshold or has enough velocity, trigger delete
    if (_dragExtent > _deleteThreshold || velocity < -500) {
      _animateToDelete();
    } else {
      _animateToStart();
    }
  }

  void _animateToStart() {
    _controller.reset();
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _dragExtent = 0.0;
        });
      }
    });
  }

  void _animateToDelete() {
    _controller.reset();
    _controller.forward().then((_) {
      if (mounted) {
        widget.onDelete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width
    _screenWidth = MediaQuery.of(context).size.width - 24; // Subtract horizontal padding
    
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Container(
        width: _screenWidth,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              left: _screenWidth - _dragExtent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: _dragExtent > 40
                    ? Center(
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 32,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Main card - full width
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final slideValue = _isDragging ? _dragExtent : _dragExtent * (1 - _animation.value);
                
                return Transform.translate(
                  offset: Offset(-slideValue, 0),
                  child: Container(
                    width: _screenWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF444444),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.member["name"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.member["email"] ?? "",
                          style: const TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}