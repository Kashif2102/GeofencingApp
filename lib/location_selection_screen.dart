import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:math' as math;

class LocationSelectionScreen extends StatefulWidget {
  @override
  _LocationSelectionScreenState createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  double _geofenceRadius = 0.0;
  bool _isButtonVisible = false;
  late LocationData _currentLocation;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _initializeLocation() async {
    final location = Location();
    final hasPermission = await location.requestPermission();
    if (hasPermission != PermissionStatus.granted) {
      return; // Location permission not granted
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
        _checkGeofence();
      });
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('earth.jpg');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _checkGeofence() {
    if (_currentLocation != null) {
      final distance = calculateDistance(
        _currentLocation.latitude!,
        _currentLocation.longitude!,
        _markers.first.position.latitude,
        _markers.first.position.longitude,
      );

      if (distance < _geofenceRadius) {
        _showNotification(
            'Geofence Crossed', 'You crossed the geofence radius');
      }
    }
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radius = 6371.0; // Radius of the earth in kilometers
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = radius * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Channel',
      'Channel for geofence notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'geofence_notification',
    );
  }

  void _removeMarker() {
    setState(() {
      _markers.clear();
      _circles.clear();
      _isButtonVisible = false;
    });
  }

  void _addMarker(LatLng location, double radius) {
    setState(() {
      _markers.clear();
      _circles.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: location,
        ),
      );
      _geofenceRadius = radius;
      _circles.add(
        Circle(
          circleId: CircleId('geofence'),
          center: location,
          radius: radius * 1000,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
      _isButtonVisible = true;
    });
  }

  Future<void> _showRadiusInputDialog(LatLng location) async {
    final radiusTextController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Geofence Radius (in kilometers)'),
          content: TextField(
            style: TextStyle(color: Colors.black),
            controller: radiusTextController,
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                final radius = double.tryParse(radiusTextController.text);
                if (radius != null) {
                  _addMarker(location, radius);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Selection'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(26.4568,
                  80.3263), // Set initial map center to Arya Nagar Chauraha, Kanpur
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            circles: _circles,
            onTap: (LatLng location) {
              _showRadiusInputDialog(location);
            },
            myLocationEnabled:
                true, // Enable showing current location on the map
            myLocationButtonEnabled:
                true, // Enables the default "My Location" button
          ),
          Visibility(
            visible: _isButtonVisible,
            child: Positioned(
              bottom: 16.0,
              left: 16.0,
              child: FloatingActionButton(
                onPressed: _removeMarker,
                child: Icon(Icons.delete),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
