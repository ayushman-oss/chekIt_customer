import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '/utils/route_transitions.dart';
import 'service_history_screen.dart';

class ServiceNodesScreen extends StatefulWidget {
  final String beltId;
  const ServiceNodesScreen({super.key, required this.beltId});

  @override
  State<ServiceNodesScreen> createState() => _ServiceNodesScreenState();
}

class _ServiceNodesScreenState extends State<ServiceNodesScreen> {
  List<Map<String, dynamic>> nodes = [];
  Map<String, int> lastKnownTimestamps = {}; // Track last timestamp per node
  bool _isRefreshing = false;
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _autoRefreshTimer;

  static const String baseUrl = "http://127.0.0.1:1880";

  @override
  void initState() {
    super.initState();
    _fetchNodes();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isRefreshing) {
        _fetchNodes();
      }
    });
  }

  Future<void> _fetchNodes() async {
    if (!mounted) return;
    
    final bool isInitialLoad = _isLoading;
    
    if (isInitialLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      // Step 1: Get list of node IDs
      final listResponse = await http.get(
        Uri.parse('$baseUrl/get-nodes').replace(queryParameters: {
          'belt_id': widget.beltId.replaceAll('-', '_'),
          'node_id': '',
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (listResponse.statusCode != 200) {
        throw Exception('Failed to fetch nodes: ${listResponse.statusCode}');
      }

      final listData = json.decode(listResponse.body);
      List<String> nodeIds = [];

      if (listData is List) {
        for (var item in listData) {
          if (item is String) {
            nodeIds.add(item);
          } else if (item is Map && item.containsKey('node_id')) {
            nodeIds.add(item['node_id'].toString());
          }
        }
      }

      if (nodeIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No nodes found for this belt';
        });
        return;
      }

      // Step 2: Fetch sensor data for each node
      List<Map<String, dynamic>> fetchedNodes = [];

      for (String nodeId in nodeIds) {
        try {
          final nodeResponse = await http.get(
            Uri.parse('$baseUrl/get-nodes').replace(queryParameters: {
              'belt_id': widget.beltId.replaceAll('-', '_'),
              'node_id': nodeId,
            }),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          if (nodeResponse.statusCode == 200) {
            final nodeData = json.decode(nodeResponse.body);
            if (nodeData is List && nodeData.isNotEmpty) {
              fetchedNodes.add(_parseNodeData(nodeData, nodeId));
            }
          }
        } catch (e) {
          print('Error fetching node $nodeId: $e');
        }
      }

      if (mounted) {
        setState(() {
          nodes = fetchedNodes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
        });
      }
      print('Error fetching nodes: $e');
    }
  }

  Map<String, dynamic> _parseNodeData(List<dynamic> readings, String nodeId) {
    // Group readings by type with full timeline
    Map<String, List<Map<String, dynamic>>> sensorTimelines = {};
    Map<String, String> sensorStatus = {};
    int? latestTimestamp;
    int? previousLatestTimestamp = lastKnownTimestamps[nodeId];

    for (var reading in readings) {
      if (reading is Map) {
        final type = reading['type']?.toString() ?? 'Unknown';
        final value = reading['value'];
        final status = reading['status']?.toString() ?? 'UNKNOWN';
        final ts = reading['ts'];

        int? timestamp;
        if (ts != null) {
          timestamp = ts is int ? ts : int.tryParse(ts.toString()) ?? 0;
          if (latestTimestamp == null || timestamp > latestTimestamp) {
            latestTimestamp = timestamp;
          }
        }

        // Initialize sensor timeline
        if (!sensorTimelines.containsKey(type)) {
          sensorTimelines[type] = [];
          sensorStatus[type] = status;
        }

        // Add reading to timeline
        if (value != null && timestamp != null) {
          sensorTimelines[type]!.add({
            'value': value is num ? value.toDouble() : value,
            'timestamp': timestamp,
            'status': status,
          });
        }

        // Keep the worst status for each sensor type
        if (_getStatusPriority(status) > _getStatusPriority(sensorStatus[type]!)) {
          sensorStatus[type] = status;
        }
      }
    }

    // Check if node is active (timestamp has updated)
    bool isActive = false;
    if (latestTimestamp != null) {
      if (previousLatestTimestamp == null || latestTimestamp > previousLatestTimestamp) {
        isActive = true;
        lastKnownTimestamps[nodeId] = latestTimestamp;
      }
    }

    // Convert sensor data to display format with timelines
    List<Map<String, dynamic>> sensors = [];
    sensorTimelines.forEach((type, timeline) {
      if (timeline.isNotEmpty) {
        // Sort by timestamp (newest first)
        timeline.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
        
        sensors.add({
          'type': _formatSensorType(type),
          'timeline': timeline.take(10).toList(), // Keep last 10 readings
          'latestValue': timeline.first['value'],
          'latestStatus': timeline.first['status'],
          'status': sensorStatus[type],
        });
      }
    });

    // Sort sensors by status priority
    sensors.sort((a, b) {
      final aPriority = _getStatusPriority(a['status']);
      final bPriority = _getStatusPriority(b['status']);
      return bPriority.compareTo(aPriority);
    });

    return {
      'id': nodeId,
      'label': _getNodeLabel(nodeId),
      'active': isActive,
      'sensors': sensors,
      'lastUpdate': latestTimestamp,
    };
  }

  int _getStatusPriority(String status) {
    if (status.contains('ERROR') || status.contains('CRITICAL')) return 3;
    if (status.contains('WARNING')) return 2;
    if (status == 'OK') return 1;
    return 0;
  }

  String _formatSensorType(String type) {
    return type
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _getNodeLabel(String nodeId) {
    final labels = {
      'node_01': 'Head Pulley Node',
      'node_02': 'Drive Motor Node',
      'node_03': 'Take-up Node',
      'node_04': 'Belt Section Node',
      'node_05': 'Tail Pulley Node',
    };
    return labels[nodeId] ?? 'Node ${nodeId.replaceAll('node_', '').toUpperCase()}';
  }

  Future<void> _refreshNodes() async {
    if (_isRefreshing || !mounted) return;
    setState(() => _isRefreshing = true);
    try {
      await _fetchNodes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nodes refreshed'),
          duration: Duration(milliseconds: 900),
          backgroundColor: Color(0xFF18D8FF),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return const Color(0xFFB0B0B0);
    if (status.contains('ERROR') || status.contains('CRITICAL')) {
      return const Color(0xFFE53E3E);
    }
    if (status.contains('WARNING')) {
      return const Color(0xFFFFA500);
    }
    if (status == 'OK') {
      return const Color(0xFF23C700);
    }
    return const Color(0xFFB0B0B0);
  }

  IconData _getSensorIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('temp')) return Icons.thermostat;
    if (lowerType.contains('vibr')) return Icons.vibration;
    if (lowerType.contains('current')) return Icons.electrical_services;
    if (lowerType.contains('power')) return Icons.bolt;
    if (lowerType.contains('speed')) return Icons.speed;
    if (lowerType.contains('load') || lowerType.contains('weight')) return Icons.scale;
    if (lowerType.contains('humid')) return Icons.water_drop;
    if (lowerType.contains('pulse') || lowerType.contains('motion') || lowerType.contains('ir')) return Icons.sensors;
    return Icons.sensors;
  }

  String _getUnit(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('temp')) return '°C';
    if (lowerType.contains('vibr')) return 'g';
    if (lowerType.contains('current')) return 'A';
    if (lowerType.contains('power')) return 'W';
    if (lowerType.contains('speed')) return 'rpm';
    if (lowerType.contains('weight')) return 'kg';
    if (lowerType.contains('humid')) return '%';
    if (lowerType.contains('pulse') || lowerType.contains('delay')) return 'ms';
    return '';
  }

  Widget _buildMiniTimeline(List<Map<String, dynamic>> timeline, String status) {
    if (timeline.length < 2) return const SizedBox.shrink();

    final statusColor = _getStatusColor(status);
    final values = timeline.map((t) => t['value'] as double).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: CustomPaint(
        size: Size.infinite,
        painter: TimelinePainter(
          timeline: timeline,
          minValue: minValue,
          maxValue: maxValue,
          range: range,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _sensorCard(Map<String, dynamic> sensor) {
    final type = sensor["type"] as String;
    final timeline = (sensor["timeline"] as List).cast<Map<String, dynamic>>();
    final latestValue = sensor["latestValue"];
    final status = sensor["status"] as String?;
    final statusColor = _getStatusColor(status);
    final unit = _getUnit(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: status != 'OK' ? statusColor.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getSensorIcon(type),
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _formatValue(latestValue),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            unit,
                            style: TextStyle(
                              color: statusColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (status != null && status != 'OK')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    status.replaceAll('_', ' '),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          _buildMiniTimeline(timeline, status ?? 'OK'),
          if (timeline.length >= 2) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${timeline.length} readings',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                Text(
                  'Trend: ${_getTrend(timeline)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getTrend(List<Map<String, dynamic>> timeline) {
    if (timeline.length < 2) return 'N/A';
    final latest = timeline[0]['value'] as double;
    final previous = timeline[1]['value'] as double;
    final diff = ((latest - previous) / previous * 100).abs();
    
    if (diff < 1) return 'Stable';
    if (latest > previous) return '↑ Rising';
    return '↓ Falling';
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) {
      if (value.abs() < 0.01 && value != 0) {
        return value.toStringAsExponential(2);
      }
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
    }
    return value.toString();
  }

  Widget _nodeCard(Map<String, dynamic> node) {
    final sensors = (node["sensors"] as List).cast<Map<String, dynamic>>();
    final isActive = (node['active'] as bool?) ?? false;
    final statusColor = isActive ? const Color(0xFF23C700) : const Color(0xFF9E9E9E);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: statusColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node["id"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        node["label"] as String,
                        style: const TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.check_circle : Icons.cancel,
                        color: statusColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sensors
          Padding(
            padding: const EdgeInsets.all(16),
            child: sensors.isNotEmpty
                ? Column(
                    children: sensors.map((s) => _sensorCard(s)).toList(),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.sensors_off, color: Colors.grey[700], size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No sensor data available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
              context, fadeRoute(const ServiceHistoryScreen())),
        ),
        title: Text(
          'Nodes — ${widget.beltId}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isRefreshing
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF18D8FF)),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refreshNodes,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF18D8FF).withOpacity(0.1),
                      const Color(0xFF18D8FF).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF18D8FF).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timeline, color: Color(0xFF18D8FF), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Real-time sensor monitoring with historical timelines',
                        style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF18D8FF),
                      ),
                    )
                  : _errorMessage.isNotEmpty
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
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchNodes,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF18D8FF),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : nodes.isEmpty
                          ? const Center(
                              child: Text(
                                'No nodes found for this belt',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24, top: 4),
                              itemCount: nodes.length,
                              itemBuilder: (context, i) => _nodeCard(nodes[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final List<Map<String, dynamic>> timeline;
  final double minValue;
  final double maxValue;
  final double range;
  final Color color;

  TimelinePainter({
    required this.timeline,
    required this.minValue,
    required this.maxValue,
    required this.range,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (timeline.length < 2 || range == 0) return;

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final spacing = size.width / (timeline.length - 1);

    // Start fill path from bottom
    fillPath.moveTo(0, size.height);

    for (int i = 0; i < timeline.length; i++) {
      final value = timeline[timeline.length - 1 - i]['value'] as double;
      final x = i * spacing;
      final normalizedValue = range > 0 ? (value - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) => true;
}