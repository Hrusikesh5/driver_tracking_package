import 'dart:async';
import 'location_service.dart';
import 'permission_service.dart';
import 'socket_manager.dart';
import 'models/driver_location.dart';

class DriverTracker {
  final _statusController = StreamController<String>.broadcast();
  final _locationController = StreamController<DriverLocation>.broadcast();

  Stream<String> get statusStream => _statusController.stream;
  Stream<DriverLocation> get locationStream => _locationController.stream;

  final PermissionService _permissionService = PermissionService();
  final LocationService _locationService = LocationService();
  SocketManager? _socketManager;
  bool _isTracking = false;

  Future<void> startTracking(String driverId) async {
    if (_isTracking) {
      _statusController.add('Already tracking');
      return;
    }

    // Check and request permissions
    bool permissionGranted =
        await _permissionService.checkAndRequestPermissions();
    if (!permissionGranted) {
      _statusController.add('Location permissions not granted');
      return;
    }

    // Initialize socket
    _socketManager = SocketManager(driverId: driverId);
    await _socketManager!.initSocket();

    // Enable background mode
    await _locationService.enableBackgroundMode();

    // Start location updates
    await _locationService.startLocationUpdates(_onLocationUpdate);

    _isTracking = true;
    _statusController.add('Tracking started');

    // Send initial location with "start" status
    await _sendCurrentLocation('start');
  }

  Future<void> stopTracking() async {
    if (!_isTracking) {
      _statusController.add('Not tracking');
      return;
    }

    // Send final location with "end" status
    await _sendCurrentLocation('end');

    // Stop location updates
    await _locationService.stopLocationUpdates();

    // Disable background mode
    await _locationService.disableBackgroundMode();

    // Close socket connection
    await _socketManager?.closeSocket();
    _socketManager = null;

    _isTracking = false;
    _statusController.add('Tracking stopped');
  }

  Future<void> _onLocationUpdate(DriverLocation location) async {
    _locationController.add(location);
    _socketManager?.sendLocation('update', location);
  }

  Future<void> _sendCurrentLocation(String status) async {
    try {
      DriverLocation location = await _locationService.getCurrentLocation();
      _locationController.add(location);
      _socketManager?.sendLocation(status, location);
    } catch (e) {
      _statusController.add('Error getting location: $e');
    }
  }

  void dispose() {
    _statusController.close();
    _locationController.close();
  }
}
