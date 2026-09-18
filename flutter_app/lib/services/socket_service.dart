import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/constants.dart';

/// Menjaga satu koneksi socket ke server yang sama dengan Admin Dashboard.
/// Setiap kali admin mengubah harga/stok produk atau status pesanan,
/// event ini diterima secara realtime tanpa perlu refresh manual.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  io.Socket get socket {
    _socket ??= io.io(
      AppConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );
    return _socket!;
  }

  void connect() {
    if (!socket.connected) socket.connect();
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
