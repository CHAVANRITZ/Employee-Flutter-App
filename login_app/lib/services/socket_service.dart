import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? _socket;

  // Port 3000 matches your backend server PORT.
  // 10.0.2.2 points to localhost from the Android emulator.
  static const String _serverUrl = 'http://10.0.2.2:3000';

  static void initSocket({required Function(Map<String, dynamic>) onNotification}) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Force pure WebSocket transport
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Connected to WebSocket server');
    });

    _socket!.on('employee_notification', (data) {
      debugPrint('Real-time event received: $data');
      if (data is Map<String, dynamic>) {
        onNotification(data);
      } else if (data is Map) {
        onNotification(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((_) => debugPrint('Disconnected from WebSocket'));
    _socket!.onConnectError((err) => debugPrint('Socket connection error: $err'));
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}