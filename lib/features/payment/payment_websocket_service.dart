//v3
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend_ecommerce/core/constants/api_constants.dart';

typedef PaymentStatusUpdateCallback = void Function(Map<String, dynamic> data);
typedef ErrorCallback = void Function(dynamic error);

class PaymentWebSocketService {
  io.Socket? _socket;

  PaymentStatusUpdateCallback? onPaymentStatusUpdate;
  ErrorCallback? onError;

  PaymentWebSocketService() {
    _socket = io.io(
      ApiConstants.baseUrlWs,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );
  }

  void connect({String? joinOrderId}) {
    debugPrint('Connecting to: ${ApiConstants.baseUrlWs}');
    _socket?.connect();

    _socket?.onConnect((_) {
      debugPrint('🟢 Socket.IO connected');
      if (joinOrderId != null) {
        _socket?.emit('joinOrderRoom', joinOrderId);
        debugPrint('📡 joinOrderRoom emitted: $joinOrderId');
      }
    });

    _socket?.on('paymentStatusUpdate', (data) {
      debugPrint('📩 Received paymentStatusUpdate: $data');
      if (data is Map<String, dynamic>) {
        onPaymentStatusUpdate?.call(data);
      }
    });

    _socket?.onDisconnect((reason) {
      debugPrint('🔌 Disconnected: $reason');
    });

    _socket?.onError((error) {
      debugPrint('❗ Error: $error');
      onError?.call(error);
    });

    _socket?.onConnectError((error) {
      debugPrint('❗ Connect error: $error');
      onError?.call(error);
    });

    _socket?.onAny((event, data) {
      debugPrint('🔍 Event: $event → $data');
    });
  }

  void disconnect() {
    debugPrint('Disconnecting...');
    _socket?.disconnect();
    _socket?.dispose();
  }

  void reconnect({String? joinOrderId}) {
    disconnect();
    connect(joinOrderId: joinOrderId);
  }
}
