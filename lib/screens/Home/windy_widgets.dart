import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WindyEmbeddedMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const WindyEmbeddedMap({
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<WindyEmbeddedMap> createState() => _WindyEmbeddedMapState();
}

class _WindyEmbeddedMapState extends State<WindyEmbeddedMap> {
  late WebViewController _controller;

  String get _embedUrl {
    final lat = widget.latitude ?? 32.7977;
    final lon = widget.longitude ?? -117.2566;
    return 'https://embed.windy.com/embed2.html?lat=$lat&lon=$lon&detailLat=$lat&detailLon=$lon&width=650&height=450&zoom=8&level=surface&overlay=wind&product=ecmwf&menu=&message=&marker=&calendar=now&pressure=&type=map&location=coordinates&detail=&metricWind=default&metricTemp=default&radarRange=-1';
  }

  void _load() {
    _controller.loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void didUpdateWidget(covariant WindyEmbeddedMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class WindyForecast extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const WindyForecast({
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<WindyForecast> createState() => _WindyForecastState();
}

class _WindyForecastState extends State<WindyForecast> {
  late WebViewController _controller;

  String get _embedUrl {
    final lat = widget.latitude ?? 32.7977;
    final lon = widget.longitude ?? -117.2566;
    // Windy.com forecast table embed (no map, just forecast)
    return 'https://embed.windy.com/embed2.html?lat=$lat&lon=$lon&width=650&height=450&detailLat=$lat&detailLon=$lon&zoom=8&level=surface&overlay=wind&product=ecmwf&menu=&message=&marker=&calendar=now&pressure=&type=forecast&location=coordinates&detail=&metricWind=default&metricTemp=default&radarRange=-1';
  }

  void _load() {
    _controller.loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void didUpdateWidget(covariant WindyForecast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class WindyWeather extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const WindyWeather({
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<WindyWeather> createState() => _WindyWeatherState();
}

class _WindyWeatherState extends State<WindyWeather> {
  late WebViewController _controller;

  String get _embedUrl {
    final lat = widget.latitude ?? 32.7977;
    final lon = widget.longitude ?? -117.2566;
    // Windy.com weather table embed (no map, just weather)
    return 'https://embed.windy.com/embed2.html?lat=$lat&lon=$lon&width=650&height=450&detailLat=$lat&detailLon=$lon&zoom=8&level=surface&overlay=wind&product=ecmwf&menu=&message=&marker=&calendar=now&pressure=&type=weather&location=coordinates&detail=&metricWind=default&metricTemp=default&radarRange=-1';
  }

  void _load() {
    _controller.loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void didUpdateWidget(covariant WindyWeather oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class WindyHistory extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const WindyHistory({
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<WindyHistory> createState() => _WindyHistoryState();
}

class _WindyHistoryState extends State<WindyHistory> {
  late WebViewController _controller;

  String get _embedUrl {
    final lat = widget.latitude ?? 32.7977;
    final lon = widget.longitude ?? -117.2566;
    // Windy.com map with temperature overlay for history
    return 'https://embed.windy.com/embed2.html?lat=$lat&lon=$lon&detailLat=$lat&detailLon=$lon&width=650&height=450&zoom=8&level=surface&overlay=temp&product=ecmwf&menu=&message=&marker=&calendar=-24h&pressure=&type=map&location=coordinates&detail=&metricWind=default&metricTemp=default&radarRange=-1';
  }

  void _load() {
    _controller.loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_embedUrl));
  }

  @override
  void didUpdateWidget(covariant WindyHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}