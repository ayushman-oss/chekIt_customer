import 'package:flutter/material.dart';
//import 'package:locationiq/locationiq.dart'; 
import 'bottom_nav.dart';

// Placeholder widgets for Windy package
class WindyMapWidget extends StatelessWidget {
  final String location;
  const WindyMapWidget({required this.location});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Windy Map for $location', style: TextStyle(color: Colors.white54, fontSize: 18)));
  }
}

class WindyForecastWidget extends StatelessWidget {
  final String location;
  const WindyForecastWidget({required this.location});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Windy Forecast for $location', style: TextStyle(color: Colors.white54, fontSize: 18)));
  }
}

class WindyWeatherWidget extends StatelessWidget {
  final String location;
  const WindyWeatherWidget({required this.location});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Windy Weather for $location', style: TextStyle(color: Colors.white54, fontSize: 18)));
  }
}

class WindyHistoryWidget extends StatelessWidget {
  final String location;
  const WindyHistoryWidget({required this.location});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Windy History for $location', style: TextStyle(color: Colors.white54, fontSize: 18)));
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _selectedTab = 0;
  String _location = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
     //final location = await LocationIQ.getCurrentLocation();
     //setState(() => _location = location);
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    setState(() {
      _location = 'California - Tourmaline'; // Placeholder
    });
  }

  Widget _getDashboardWidget() {
    switch (_selectedTab) {
      case 0:
        return WindyMapWidget(location: _location);
      case 1:
        return WindyForecastWidget(location: _location);
      case 2:
        return WindyWeatherWidget(location: _location);
      case 3:
        return WindyHistoryWidget(location: _location);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hey!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Colin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF18D8FF)),
                      const SizedBox(width: 4),
                      Text(
                        _location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _tabButton('Map', 0),
                  _tabButton('Forecast', 1),
                  _tabButton('Weather', 2),
                  _tabButton('History', 3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: _getDashboardWidget(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // TODO: Handle navigation for other tabs
          });
        },
      ),
    );
  }

  Widget _tabButton(String label, int tabIndex) {
    final selected = _selectedTab == tabIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabIndex;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF18D8FF) : const Color(0xFF232323),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : const Color(0xFF18D8FF),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}