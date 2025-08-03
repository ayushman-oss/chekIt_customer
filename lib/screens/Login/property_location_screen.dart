import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Constants for better maintainability
class PropertyLocationConstants {
  static const String locationIqApiKey = 'pk.40073c72697579dc5d283aa9cb80ea7a';
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF2A2A2A);
  static const Color primaryBlue = Color(0xFF6DDCFF);
  static const Color orange = Colors.orange;
  
  static const double defaultPadding = 16.0;
  static const double borderRadius = 20.0;
  static const double searchBorderRadius = 28.0;
  static const int searchDebounceMs = 500;
  static const int suggestionLimit = 5;
  static const int minSearchLength = 3;
}

class PropertyLocationScreen extends StatefulWidget {
  const PropertyLocationScreen({super.key});

  @override
  State<PropertyLocationScreen> createState() => _PropertyLocationScreenState();
}

class _PropertyLocationScreenState extends State<PropertyLocationScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final MapController _mapController = MapController();
  
  // Location state
  double _latitude = 37.7749; // Default to San Francisco
  double _longitude = -122.4194;
  String? _selectedAddress;
  List<LocationSuggestion> _suggestions = [];
  
  // UI state
  bool _isLoadingLocation = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  bool _isReverseGeocoding = false;
  bool _isTyping = false;
  Timer? _searchDebouncer;
  Timer? _reverseGeocodeDebouncer;
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _areaController.dispose();
    _searchFocusNode.dispose();
    _searchDebouncer?.cancel();
    _reverseGeocodeDebouncer?.cancel();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _requestLocationPermission();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFieldFocusChanged);
    // Get initial address for default location
    await _reverseGeocode(_latitude, _longitude);
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted && mounted) {
      _showSnackBar('Location permission is required for better experience');
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;
    
    setState(() => _isLoadingLocation = true);
    
    try {
      final status = await Permission.location.status;
      if (!status.isGranted) {
        final newStatus = await Permission.location.request();
        if (!newStatus.isGranted) {
          _showSnackBar('Location permission denied');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        
        // Move map to current location
        _mapController.move(LatLng(_latitude, _longitude), 15.0);
        await _reverseGeocode(_latitude, _longitude);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to get current location: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _reverseGeocode(double lat, double lon) async {
    setState(() => _isReverseGeocoding = true);
    
    try {
      final url = 'https://us1.locationiq.com/v1/reverse'
          '?key=${PropertyLocationConstants.locationIqApiKey}'
          '&lat=$lat&lon=$lon&format=json';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          _selectedAddress = data['display_name'];
          // Always update search field with the pin location unless user is actively typing
          if (!_searchFocusNode.hasFocus || !_isTyping) {
            _searchController.text = _selectedAddress ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to get address details');
      }
    } finally {
      if (mounted) {
        setState(() => _isReverseGeocoding = false);
      }
    }
  }

  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (hasGesture && position.center != null) {
      final newLat = position.center!.latitude;
      final newLon = position.center!.longitude;
      
      setState(() {
        _latitude = newLat;
        _longitude = newLon;
      });
      
      // Debounce reverse geocoding to avoid too many API calls
      _reverseGeocodeDebouncer?.cancel();
      _reverseGeocodeDebouncer = Timer(
        const Duration(milliseconds: 500),
        () => _reverseGeocode(newLat, newLon),
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    // Mark as typing
    _isTyping = true;
    
    // Cancel previous search
    _searchDebouncer?.cancel();
    
    if (query.length < PropertyLocationConstants.minSearchLength) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });
    
    // Debounce search requests
    _searchDebouncer = Timer(
      const Duration(milliseconds: PropertyLocationConstants.searchDebounceMs),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    try {
      final url = 'https://us1.locationiq.com/v1/autocomplete'
          '?key=${PropertyLocationConstants.locationIqApiKey}'
          '&q=${Uri.encodeComponent(query)}'
          '&limit=${PropertyLocationConstants.suggestionLimit}'
          '&format=json';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          _suggestions = data
              .cast<Map<String, dynamic>>()
              .map((item) => LocationSuggestion.fromJson(item))
              .where((suggestion) => suggestion.isValid)
              .toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
        _showSnackBar('Search failed. Please try again.');
      }
    }
  }

  void _onSuggestionTap(LocationSuggestion suggestion) {
    setState(() {
      _selectedAddress = suggestion.displayName;
      _searchController.text = suggestion.displayName;
      _latitude = suggestion.latitude!;
      _longitude = suggestion.longitude!;
      _suggestions = [];
      _showSuggestions = false;
      _isTyping = false;
    });
    
    // Move map to selected location
    _mapController.move(LatLng(_latitude, _longitude), 15.0);
    
    // Hide keyboard
    _searchFocusNode.unfocus();
  }

  void _onSearchFieldSubmitted(String value) {
    setState(() {
      _showSuggestions = false;
      _isTyping = false;
    });
    _searchFocusNode.unfocus();
  }

  void _onSearchFieldFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      // Delay hiding suggestions to allow for tap events
      Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
            _isTyping = false;
          });
        }
      });
    } else {
      // Show suggestions when field is focused and has content
      if (_searchController.text.trim().length >= PropertyLocationConstants.minSearchLength) {
        setState(() {
          _showSuggestions = true;
          _isTyping = true;
        });
      }
    }
  }

  void _onConfirmLocation() {
    if (_searchController.text.trim().isEmpty) {
      _showSnackBar('Please select a location');
      return;
    }
    
    if (_areaController.text.trim().isEmpty) {
      _showSnackBar('Please enter property area');
      return;
    }

    Navigator.pop(context, {
      'address': _searchController.text.trim(),
      'area': _areaController.text.trim(),
      'lat': _latitude,
      'lng': _longitude,
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PropertyLocationConstants.cardColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PropertyLocationConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildInteractiveMap(),
          _buildSearchSection(),
          _buildMapControls(),
          _buildCenterPin(),
          _buildLocationButton(),
          _buildBottomSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: PropertyLocationConstants.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Property Location',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildInteractiveMap() {
    return Positioned.fill(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(_latitude, _longitude),
          zoom: 15,
          onPositionChanged: _onMapPositionChanged,
          interactiveFlags: InteractiveFlag.all,
        ),
        children: [
          TileLayer(
            // Using dark mode tiles
            urlTemplate: 'https://tiles.locationiq.com/v3/dark/r/{z}/{x}/{y}.png?key=${PropertyLocationConstants.locationIqApiKey}',
            additionalOptions: const {
              'attribution': '© LocationIQ',
            },
            backgroundColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Positioned(
      top: 24,
      left: PropertyLocationConstants.defaultPadding,
      right: PropertyLocationConstants.defaultPadding,
      child: Column(
        children: [
          _buildSearchBar(),
          if (_showSuggestions && _searchFocusNode.hasFocus && (_suggestions.isNotEmpty || _isSearching)) 
            _buildSuggestionsList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(Icons.search, color: Colors.white, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              onSubmitted: _onSearchFieldSubmitted,
              decoration: const InputDecoration(
                hintText: 'Search Address',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
          ),
          if (_isSearching || _isReverseGeocoding)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(
        maxHeight: 300, // Limit height to prevent covering everything
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: _isSearching
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Searching...',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.1),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: PropertyLocationConstants.primaryBlue,
                    size: 20,
                  ),
                  title: Text(
                    suggestion.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _onSuggestionTap(suggestion),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 100,
      right: 24,
      child: Column(
        children: [
          // Home icon
          Container(
            decoration: BoxDecoration(
              color: PropertyLocationConstants.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.home,
              color: PropertyLocationConstants.orange,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // Distance indicator
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: const Text(
              '50m',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPin() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: PropertyLocationConstants.primaryBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Move pin to your exact location',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Custom location pin matching Figma
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PropertyLocationConstants.primaryBlue.withOpacity(0.2),
              border: Border.all(
                color: PropertyLocationConstants.primaryBlue,
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: PropertyLocationConstants.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PropertyLocationConstants.primaryBlue.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Positioned(
      bottom: 270,
      left: 24,
      right: 24,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: TextButton.icon(
          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
          icon: _isLoadingLocation
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: PropertyLocationConstants.primaryBlue,
                  ),
                )
              : const Icon(
                  Icons.my_location,
                  color: PropertyLocationConstants.primaryBlue,
                  size: 20,
                ),
          label: Text(
            _isLoadingLocation ? 'Getting Location...' : 'Use Current Location',
            style: const TextStyle(
              color: PropertyLocationConstants.primaryBlue,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: PropertyLocationConstants.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          PropertyLocationConstants.defaultPadding,
          24,
          PropertyLocationConstants.defaultPadding,
          60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Property Area (sq. ft.)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: PropertyLocationConstants.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PropertyLocationConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PropertyLocationConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PropertyLocationConstants.borderRadius),
                  borderSide: const BorderSide(
                    color: PropertyLocationConstants.primaryBlue,
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                hintText: 'Enter area in sq. ft.',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PropertyLocationConstants.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PropertyLocationConstants.borderRadius),
                  ),
                  elevation: 0,
                ),
                onPressed: _onConfirmLocation,
                child: const Text(
                  'Confirm Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for location suggestions
class LocationSuggestion {
  final String displayName;
  final double? latitude;
  final double? longitude;

  LocationSuggestion({
    required this.displayName,
    this.latitude,
    this.longitude,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_place'] ?? json['display_name'] ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? ''),
      longitude: double.tryParse(json['lon']?.toString() ?? ''),
    );
  }

  bool get isValid => displayName.isNotEmpty && latitude != null && longitude != null;
}