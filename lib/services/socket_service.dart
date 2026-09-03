import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static IO.Socket? _socket;

  static void initSocket({required Function(Map<String, dynamic>) onNewOrder}) {
    if (_socket != null && _socket!.connected) return;

    final String socketUrl = kIsWeb
        ? 'http://localhost:3001'
        : 'http://127.0.0.1:3001';

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('⚡ Connected to Real-time Socket Server at $socketUrl');
    });

    _socket!.on('new-order', (data) {
      debugPrint('📢 Real-time Socket Event: new-order received: $data');
      if (data != null && data is Map) {
        onNewOrder(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Disconnected from Socket Server');
    });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
