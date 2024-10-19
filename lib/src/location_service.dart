import 'dart:async';
import 'package:location/location.dart';
import 'models/driver_location.dart';

class LocationService {
  final Location _location = Location();
  Stream<DriverLocation>? _locationStream;
  StreamSubscription<DriverLocation>? _locationSubscription;

  Future<void> enableBackgroundMode() async {
    await _location.enableBackgroundMode(enable: true);
  }

  Future<void> disableBackgroundMode() async {
    await _location.enableBackgroundMode(enable: false);
  }

  Future<void> startLocationUpdates(
      Function(DriverLocation) onLocationUpdate) async {
    _locationStream = _location.onLocationChanged.map((locationData) {
      return DriverLocation(
        latitude: locationData.latitude ?? 0.0,
        longitude: locationData.longitude ?? 0.0,
      );
    });

    _locationSubscription = _locationStream!.listen(onLocationUpdate);
  }

  Future<void> stopLocationUpdates() async {
    await _locationSubscription?.cancel();
  }

  Future<DriverLocation> getCurrentLocation() async {
    LocationData locationData = await _location.getLocation();
    return DriverLocation(
      latitude: locationData.latitude ?? 0.0,
      longitude: locationData.longitude ?? 0.0,
    );
  }
}
