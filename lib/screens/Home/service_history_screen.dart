import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/route_transitions.dart';
import 'dashboard.dart';
import 'bottom_nav.dart';
import 'notification_screen.dart';
import 'service_nodes_screen.dart';
import 'gemini_chat_screen.dart';

const stepTypes = {
  "alert": {
    "icon": "assets/icons/Alert.svg",
    "label": "Alert Initiated",
    "color": Color.fromARGB(255, 23, 199, 0),
  },
  "accepted": {
    "icon": "assets/icons/Tick.svg",
    "label": "Accepted",
    "color": Color.fromARGB(255, 23, 199, 0),
  },
  "driver": {
    "icon": "assets/icons/Delivery.svg",
    "label": "Driver Arrived",
    "color": Color.fromARGB(255, 23, 199, 0),
  },
  "sprayed": {
    "icon": "assets/icons/Service.svg",
    "label": "Sprayed",
    "color": Color.fromARGB(255, 23, 199, 0),
  },
};

const statusColors = {
  "Running": Color(0xFF18D8FF),
  "Halted": Color(0xFFE53E3E),
  "Servicing": Color(0xFFFFA500),
  "Breakdown": Color(0xFFE23E3E),
  "OK": Color(0xFF18D8FF),
  "WARNING": Color(0xFFFFA500),
  "CRITICAL": Color(0xFFE53E3E),
  "Unknown": Color(0xFFB0B0B0),
};

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  int? expandedIndex;
  int _currentIndex = 1;
  List<Map<String, dynamic>> belts = [];
  bool isLoading = true;
  String errorMessage = '';

  // Update this to your Node-RED server address
  static const String baseUrl = "http://127.0.0.1:1880";

  @override
  void initState() {
    super.initState();
    fetchBelts();
  }

  Future<void> fetchBelts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Step 1: Get list of all belt IDs by passing empty string
      final listResponse = await http.get(
        Uri.parse('$baseUrl/get-belt').replace(queryParameters: {'belt_id': ''}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (listResponse.statusCode != 200) {
        throw Exception('Failed to fetch belt list: ${listResponse.statusCode}');
      }

      final listData = json.decode(listResponse.body);
      List<String> beltIds = [];

      // Extract belt IDs from response
      if (listData is List) {
        for (var item in listData) {
          if (item is String) {
            beltIds.add(item);
          } else if (item is Map) {
            if (item.containsKey('conveyor_id')) {
              beltIds.add(item['conveyor_id'].toString());
            } else if (item.containsKey('belt_id')) {
              beltIds.add(item['belt_id'].toString());
            } else if (item.containsKey('id')) {
              beltIds.add(item['id'].toString());
            }
          }
        }
      } else if (listData is Map) {
        if (listData.containsKey('belts')) {
          final beltsData = listData['belts'];
          if (beltsData is List) {
            for (var item in beltsData) {
              if (item is String) {
                beltIds.add(item);
              } else if (item is Map) {
                if (item.containsKey('conveyor_id')) {
                  beltIds.add(item['conveyor_id'].toString());
                } else if (item.containsKey('belt_id')) {
                  beltIds.add(item['belt_id'].toString());
                } else if (item.containsKey('id')) {
                  beltIds.add(item['id'].toString());
                }
              }
            }
          }
        } else if (listData.containsKey('belt_ids')) {
          final idsData = listData['belt_ids'];
          if (idsData is List) {
            beltIds = idsData.map((id) => id.toString()).toList();
          }
        }
      }

      print('Found ${beltIds.length} belt IDs: $beltIds');

      // Filter out non-belt IDs (nodes, readings, uploads are not actual belts)
      beltIds = beltIds.where((id) => 
        !id.toLowerCase().contains('node') && 
        !id.toLowerCase().contains('reading') && 
        !id.toLowerCase().contains('upload')
      ).toList();

      print('Filtered to ${beltIds.length} valid belt IDs: $beltIds');

      if (beltIds.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'No belts found';
        });
        return;
      }

      // Step 2: Fetch sensor readings for each belt
      List<Map<String, dynamic>> fetchedBelts = [];
      
      for (String beltId in beltIds) {
        try {
          final detailResponse = await http.get(
            Uri.parse('$baseUrl/get-belt').replace(
              queryParameters: {'belt_id': beltId}
            ),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          if (detailResponse.statusCode == 200) {
            final responseData = json.decode(detailResponse.body);
            
            // The API returns a list of sensor readings
            if (responseData is List && responseData.isNotEmpty) {
              fetchedBelts.add(parseBeltFromReadings(responseData, beltId));
            }
          }
        } catch (e) {
          print('Error fetching belt $beltId: $e');
        }
      }

      setState(() {
        belts = fetchedBelts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
      print('Error fetching belts: $e');
    }
  }

  Map<String, dynamic> parseBeltFromReadings(List<dynamic> readings, String beltId) {
    // Group readings by timestamp to create log entries
    Map<int, List<Map<String, dynamic>>> readingsByTime = {};
    String currentStatus = 'Unknown';
    DateTime? lastUpdateTime;
    
    for (var reading in readings) {
      if (reading is Map) {
        final ts = reading['ts'];
        final status = reading['status']?.toString() ?? 'Unknown';
        
        // Track the most recent status
        if (lastUpdateTime == null || (ts is int && ts > (readingsByTime.keys.isNotEmpty ? readingsByTime.keys.reduce((a, b) => a > b ? a : b) : 0))) {
          currentStatus = status;
        }
        
        if (ts != null) {
          final timestamp = ts is int ? ts : int.tryParse(ts.toString()) ?? 0;
          if (!readingsByTime.containsKey(timestamp)) {
            readingsByTime[timestamp] = [];
          }
          readingsByTime[timestamp]!.add({
            'type': reading['type'],
            'value': reading['value'],
            'status': status,
            'node_id': reading['node_id'],
          });
        }
      }
    }

    // Get the last 3 unique timestamps for logs
    final sortedTimestamps = readingsByTime.keys.toList()..sort((a, b) => b.compareTo(a));
    final lastThreeTimestamps = sortedTimestamps.take(3).toList();
    
    List<Map<String, dynamic>> logs = [];
    for (var timestamp in lastThreeTimestamps) {
      final readingsAtTime = readingsByTime[timestamp]!;
      final firstReading = readingsAtTime.first;
      
      // Determine event type based on readings
      String event = 'Running';
      String notes = '';
      
      if (readingsAtTime.any((r) => r['status'] == 'CRITICAL')) {
        event = 'Breakdown';
        notes = 'Critical sensor readings detected';
      } else if (readingsAtTime.any((r) => r['status'] == 'WARNING')) {
        event = 'Servicing';
        notes = 'Warning conditions detected';
      } else {
        event = 'Running';
        final types = readingsAtTime.map((r) => r['type']).join(', ');
        notes = 'Monitoring: $types';
      }
      
      logs.add({
        'time': _formatTime(timestamp),
        'event': event,
        'operator': firstReading['node_id'] ?? 'System',
        'notes': notes,
      });
    }

    // Derive belt status from sensor readings
    if (currentStatus == 'CRITICAL') {
      currentStatus = 'Breakdown';
    } else if (currentStatus == 'WARNING') {
      currentStatus = 'Servicing';
    } else if (currentStatus == 'OK') {
      currentStatus = 'Running';
    }

    // Parse belt metadata from ID (e.g., CV_101 -> CV-101)
    String displayId = beltId.replaceAll('_', '-');
    
    // Get the most recent timestamp for last updated
    final mostRecentTs = sortedTimestamps.isNotEmpty ? sortedTimestamps.first : null;
    
    return {
      'id': displayId,
      'material': _getMaterialFromBeltId(beltId),
      'source': _getSourceFromBeltId(beltId),
      'destination': _getDestinationFromBeltId(beltId),
      'lastUpdated': _formatDate(mostRecentTs),
      'status': currentStatus,
      'logs': logs,
    };
  }

  String _getMaterialFromBeltId(String beltId) {
    // Map belt IDs to materials (customize based on your setup)
    final materials = {
      'CV_101': 'Bauxite',
      'CV_102': 'Bauxite',
      'CV_105': 'Crushed Bauxite',
      'CV_201': 'Alumina',
      'beltA': 'Raw Material',
      'beltB': 'Processed Material',
    };
    return materials[beltId] ?? 'Unknown Material';
  }

  String _getSourceFromBeltId(String beltId) {
    final sources = {
      'CV_101': 'Mines Yard',
      'CV_102': 'Mines Yard',
      'CV_105': 'Crusher House',
      'CV_201': 'Calcination Section',
      'beltA': 'Storage A',
      'beltB': 'Storage B',
    };
    return sources[beltId] ?? 'Unknown Source';
  }

  String _getDestinationFromBeltId(String beltId) {
    final destinations = {
      'CV_101': 'Crusher Unit',
      'CV_102': 'Crusher Unit',
      'CV_105': 'Pre-blending Yard',
      'CV_201': 'Storage Silos',
      'beltA': 'Processing Unit A',
      'beltB': 'Processing Unit B',
    };
    return destinations[beltId] ?? 'Unknown Destination';
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      DateTime dt;
      if (timestamp is int) {
        // Handle both milliseconds and seconds timestamps
        if (timestamp > 10000000000) {
          dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else {
          dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        }
      } else {
        dt = DateTime.parse(timestamp.toString());
      }
      
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? "PM" : "AM";
      return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timestamp.toString();
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      DateTime dt;
      if (timestamp is int) {
        // Handle both milliseconds and seconds timestamps
        if (timestamp > 10000000000) {
          dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else {
          dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        }
      } else {
        dt = DateTime.parse(timestamp.toString());
      }
      
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (e) {
      return timestamp.toString();
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
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pushReplacement(
                        context, fadeRoute(const DashboardScreen())),
                  ),
                  const Spacer(),
                  const Text(
                    "Conveyor Belts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                    onPressed: fetchBelts,
                  ),
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
                child: const Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(Icons.search, color: Color(0xFF18D8FF), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Search belts, sources or destinations",
                        style: TextStyle(
                          color: Color(0xFF18D8FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF18D8FF),
                      ),
                    )
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: fetchBelts,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF18D8FF),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : belts.isEmpty
                          ? const Center(
                              child: Text(
                                'No belts available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 12, bottom: 24),
                              itemCount: belts.length,
                              itemBuilder: (context, idx) {
                                final item = belts[idx];
                                final isExpanded = expandedIndex == idx;
                                final logs = (item["logs"] as List?) ?? [];
                                final status = (item["status"] as String?) ?? "Unknown";
                                final statusColor =
                                    statusColors[status] ?? statusColors["Unknown"]!;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isExpanded) {
                                        final beltId = item["id"] as String;
                                        Navigator.push(
                                            context,
                                            fadeRoute(ServiceNodesScreen(
                                                beltId: beltId)));
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF292929),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Top Row
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ID & Material
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item["id"] as String,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    item["material"] as String,
                                                    style: const TextStyle(
                                                      color: Color(0xFFB0B0B0),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 12),

                                              // Source → Destination
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    "${item["source"]}  →  ${item["destination"]}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),

                                              // Date & Status
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    item["lastUpdated"] as String,
                                                    style: const TextStyle(
                                                      color: Color(0xFFB0B0B0),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        expandedIndex = isExpanded
                                                            ? null
                                                            : idx;
                                                      });
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 10,
                                                                  vertical: 6),
                                                          decoration: BoxDecoration(
                                                            color: statusColor
                                                                .withOpacity(0.12),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(12),
                                                            border: Border.all(
                                                              color: statusColor
                                                                  .withOpacity(0.4),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            status,
                                                            style: TextStyle(
                                                              color: statusColor,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Icon(
                                                          isExpanded
                                                              ? Icons
                                                                  .keyboard_arrow_up
                                                              : Icons
                                                                  .keyboard_arrow_down,
                                                          color: const Color(
                                                              0xFFB0B0B0),
                                                          size: 30,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          // Logs
                                          if (isExpanded && logs.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            Column(
                                              children:
                                                  List.generate(logs.length, (i) {
                                                final log = logs[i] as Map;
                                                final isLast = i == logs.length - 1;

                                                return Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 12.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      // Timeline indicator
                                                      SizedBox(
                                                        width: 40,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width: 12,
                                                              height: 12,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color:
                                                                    Colors.white,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            if (!isLast)
                                                              Container(
                                                                width: 2,
                                                                height: 56,
                                                                color: const Color(
                                                                    0xFF3A3A3A),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 6),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),

                                                      // Log content
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  log["time"]
                                                                      as String,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Color(
                                                                        0xFFB0B0B0),
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical: 4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: (statusColors[log[
                                                                                "event"]] ??
                                                                            const Color(
                                                                                0xFFB0B0B0))
                                                                        .withOpacity(
                                                                            0.08),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    border:
                                                                        Border.all(
                                                                      color: (statusColors[log[
                                                                                  "event"]] ??
                                                                              const Color(
                                                                                  0xFFB0B0B0))
                                                                          .withOpacity(
                                                                              0.3),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    log["event"]
                                                                        as String,
                                                                    style:
                                                                        TextStyle(
                                                                      color: statusColors[log[
                                                                              "event"]] ??
                                                                          const Color(
                                                                              0xFFB0B0B0),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize: 13,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Flexible(
                                                                  child: Text(
                                                                    log["operator"]
                                                                        as String,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Color(
                                                                          0xFFB0B0B0),
                                                                      fontSize: 13,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 6),
                                                            Text(
                                                              log["notes"]
                                                                  as String,
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFF9E9E9E),
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ],
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
            Navigator.pushReplacement(
                context, fadeRoute(const DashboardScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, fadeRoute(const ServiceHistoryScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, fadeRoute(const GeminiChatScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context, fadeRoute(const NotificationScreen()));
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