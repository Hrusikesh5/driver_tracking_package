import 'package:location/location.dart';

class PermissionService {
  final Location _location = Location();

  Future<bool> checkAndRequestPermissions() async {
    PermissionStatus permissionGranted = await _location.hasPermission();

    if (permissionGranted == PermissionStatus.granted ||
        permissionGranted == PermissionStatus.grantedLimited) {
      return true;
    }

    permissionGranted = await _location.requestPermission();

    if (permissionGranted == PermissionStatus.granted ||
        permissionGranted == PermissionStatus.grantedLimited) {
      return true;
    }

    return false;
  }
}
