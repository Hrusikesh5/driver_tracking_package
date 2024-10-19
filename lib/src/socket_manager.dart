import 'dart:developer';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'models/driver_location.dart';

class SocketManager {
  static const String _socketURL =
      "wss://phoenix-tracking-backend.onrender.com/socket/websocket";

  PhoenixSocket? _socket;
  PhoenixChannel? _channel;
  final String driverId;

  SocketManager({required this.driverId});

  Future<void> initSocket() async {
    _socket = PhoenixSocket(_socketURL,
        socketOptions: PhoenixSocketOptions(params: {"vsn": "2.0.0"}));

    await _socket!.connect();
    log("Socket connected");

    _channel = _socket!.channel("tracking:driver:$driverId");
    var joinPush = _channel!.join();

    if (joinPush != null) {
      joinPush
          .receive("ok",
              (_) => log("Successfully joined channel for driver $driverId"))
          .receive("error", (err) => log("Failed to join channel: $err"));
    } else {
      log("Join operation failed to return a PhoenixPush object.");
    }
  }

  void sendLocation(String status, DriverLocation location) {
    if (_channel != null) {
      _channel!.push(event: "location_update", payload: {
        "id": driverId,
        "lat": location.latitude,
        "lon": location.longitude,
        "status": status,
      });
      log("Status: $status, Lat: ${location.latitude}, Lon: ${location.longitude}, Driver ID: $driverId");
    } else {
      log("Cannot send location: channel is null");
    }
  }

  Future<void> closeSocket() async {
    if (_channel != null) {
      var leavePush = _channel!.leave();

      if (leavePush != null) {
        leavePush
            .receive("ok", (_) => log("Left the channel successfully"))
            .receive("error", (err) => log("Failed to leave channel: $err"));
      } else {
        log("Leave operation failed to return a PhoenixPush object.");
      }
    }

    await _socket?.disconnect();
    log("Socket disconnected");
  }
}
