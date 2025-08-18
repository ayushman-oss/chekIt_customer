import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bottom_nav.dart';
import 'windy_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'profile_screen.dart';
import 'menu_screen.dart';
import 'service_screen.dart';
import '/utils/route_transitions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _selectedTab = 0;
  String _location = 'Fetching location...';
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkAndFetchLocation();
      }
    });
  }

  Future<void> _checkAndFetchLocation() async {
    if (_isLoadingLocation || !mounted) return;
    
    setState(() {
      _isLoadingLocation = true;
      _location = 'Checking permissions...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _location = 'Location services disabled';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _location = 'Location permission denied';
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _location = 'Location permission permanently denied';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      await _fetchLocation();
    } catch (e) {
      if (mounted) {
        setState(() {
          _location = 'Error: ${e.toString()}';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    
    setState(() {
      _location = 'Getting location...';
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      final lat = position.latitude;
      final lon = position.longitude;

      if (mounted) {
        setState(() {
          _latitude = lat;
          _longitude = lon;
          _location = 'Getting address...';
        });
        await _reverseGeocode(lat, lon);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _location = 'Failed to get location';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
    try {
      String? locationName = await _tryLocationIQ(lat, lon);
      locationName ??= await _tryNominatim(lat, lon);
      
      if (mounted) {
        setState(() {
          _location = locationName ?? 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _location = 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<String?> _tryLocationIQ(double lat, double lon) async {
    try {
      final url = 'https://us1.locationiq.com/v1/reverse'
          '?key=pk.a81c4aa0e5c998f9c8ed9684b7017b60'
          '&lat=$lat&lon=$lon&format=json&accept-language=en';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        
        if (address != null) {
          final city = address['city'] ?? address['town'] ?? address['village'];
          final state = address['state'] ?? address['region'];
          
          if (city != null && state != null) {
            return '$city, $state';
          }
        }
        return data['display_name']?.toString().split(',').take(2).join(', ');
      }
    } catch (e) {
      // Silent fail, will try next service
    }
    return null;
  }

  Future<String?> _tryNominatim(double lat, double lon) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=$lat&lon=$lon&accept-language=en';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'WeatherApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        
        if (address != null) {
          final city = address['city'] ?? address['town'] ?? address['village'];
          final state = address['state'];
          
          if (city != null && state != null) {
            return '$city, $state';
          }
        }
        return data['display_name']?.toString().split(',').take(2).join(', ');
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Status bar space
          SizedBox(height: MediaQuery.of(context).padding.top),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting and Name (left)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hey!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Colin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF3DDC97), size: 34),
                        const SizedBox(width: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            _location,
                            style: const TextStyle(
                              color: Color(0xFFD1F5E6),
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                              height: 1.0,
                            ),
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        if (_isLoadingLocation)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF18D8FF)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Tabs
                Row(
                  children: [
                    _tabButton('Map', 0),
                    const SizedBox(width: 10),
                    _tabButton('Forecast', 1),
                    const SizedBox(width: 10),
                    _tabButton('Weather', 2),
                    const SizedBox(width: 10),
                    _tabButton('History', 3),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 4), // Small bottom margin to prevent overflow
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  WindyEmbeddedMap(
                    //location: _location,
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                  WindyForecast(
                    //location: _location,
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                  WindyWeather(
                    //location: _location,
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                  WindyHistory(
                    //location: _location,
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          if (index == 1) {
            Navigator.pushReplacement(context, fadeRoute(const ProfileScreen()));
          } else if (index == 4) {
            Navigator.pushReplacement(context, fadeRoute(const MenuScreen()));
          }  else if (index == 3) {
            Navigator.pushReplacement(context, fadeRoute(const Service()));
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
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
      child: Container(
        height: 36,
        width: 104,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF18D8FF) : const Color(0xFF232323),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : const Color(0xFF18D8FF),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}