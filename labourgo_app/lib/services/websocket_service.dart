import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  late String _bookingId;
  String? _token;

  Stream<dynamic>? get stream => _channel.stream;

  Future<void> connect(int bookingId) async {
    _bookingId = bookingId.toString();
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');

    final wsUrl = Uri.parse(
      'http://kgz17l6w-8000.inc1.devtunnels.ms/ws/chat/$_bookingId/?token=$_token',
    );

    _channel = WebSocketChannel.connect(wsUrl);
  }

  void sendMessage(String message) {
    _channel.sink.add(jsonEncode({'message': message}));
  }

  void disconnect() {
    _channel.sink.close();
  }
}
