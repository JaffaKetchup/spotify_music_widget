import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

Stream<Map<String, dynamic>> listenToSocket() async* {
  late final Socket socket;

  try {
    socket = await Socket.connect('127.0.0.1', 65535);
  } catch (e) {
    debugPrint('Socket \'127.0.0.1:65535\' was unavailable for connection');
    throw const SocketException(
        'Socket \'127.0.0.1:65535\' was unavailable for connection');
  }

  await for (Uint8List incoming in socket) {
    try {
      yield json.decode(String.fromCharCodes(incoming)) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Recieved invalid data from API\n$e\nContinuing listening...');
    }
  }

  socket.destroy();

  debugPrint('Socket was destroyed at end of connection');
  throw const SocketException('Socket was destroyed at end of connection');
}
