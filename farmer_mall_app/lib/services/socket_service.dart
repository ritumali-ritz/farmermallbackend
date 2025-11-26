import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api_service.dart';

class SocketService {
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  io.Socket? _socket;

  io.Socket? get socket => _socket;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await ApiService.getToken();
    final base = Uri.parse(ApiService.baseUrl);
    final resolvedPort = base.hasPort
        ? base.port
        : base.scheme == 'https'
            ? 443
            : 80;
    final origin = '${base.scheme}://${base.host}:$resolvedPort';

    _socket = io.io(
      origin,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setQuery(token != null ? {'token': token} : {})
          .build(),
    );

    _socket!
      ..onConnect((_) => debugPrint('Socket connected'))
      ..onDisconnect((_) => debugPrint('Socket disconnected'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.close();
    _socket = null;
  }
}
