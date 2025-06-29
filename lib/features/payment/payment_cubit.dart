//15 20.25
// payment_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_ecommerce/core/constants/api_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import './payment_remote_datasource.dart';
import './payment_success_model.dart';

// --- States ---
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSuccess extends PaymentState {
  final PaymentSuccessModel paymentDetails;

  const PaymentSuccess(this.paymentDetails);

  @override
  List<Object?> get props => [paymentDetails];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---
class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRemoteDatasource datasource;
  PaymentSuccessModel? _lastPaymentDetails; // <-- Tambahkan ini

  PaymentCubit(this.datasource) : super(const PaymentInitial());

  IO.Socket? _socket;

  /// Buat pembayaran berdasarkan orderId
  Future<void> createPayment(
      String orderId, int totalAmount, List<Map<String, dynamic>> items) async {
    emit(const PaymentLoading());
    try {
      final paymentDetails = await datasource.createPayment(orderId);

      if (kDebugMode) {
        print('DEBUG: PaymentSuccessModel from datasource:');
        print('  orderId: ${paymentDetails.orderId}');
        print('  grossAmount: ${paymentDetails.grossAmount}');
        print('  transactionStatus: ${paymentDetails.transactionStatus}');
        print('  paymentType: ${paymentDetails.paymentType}');
        print('  bank: ${paymentDetails.bank}');
        print('  vaNumber: ${paymentDetails.vaNumber}');
      }

      _lastPaymentDetails = paymentDetails; // <-- Simpan detail pembayaran awal

      if (kDebugMode) print('Payment created: $paymentDetails');

      // Hubungkan ke Socket.IO setelah payment berhasil
      _connectToSocket(orderId);

      emit(PaymentSuccess(paymentDetails));
    } catch (e) {
      emit(PaymentError('Gagal memproses pembayaran: $e'));
    }
  }

  /// Koneksi ke WebSocket dan dengarkan event dari server
  void _connectToSocket(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket!.disconnect();
    }

    _socket = IO.io(
      ApiConstants.baseUrlWs, // <-- Gunakan constanta ini
      // 'https://44ba-66-96-225-191.ngrok-free.app',
      // 'http://10.0.2.2:3000', // ganti IP sesuai server kamu
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('🟢 Socket connected!');
      _socket!.emit('joinOrderRoom', orderId); // ⬅️ Emit di sini
      print('📡 joinOrderRoom emitted with $orderId');
    });

    _socket!.on('paymentStatusUpdate', (data) {
      if (kDebugMode) print('📩 Received status update: $data');
      if (data is Map<String, dynamic>) {
        final receivedOrderId = data['orderId'] ?? '';
        final status = data['status'] ?? '';
        final paymentType =
            data['paymentType'] as String?; // Ambil dari data WebSocket
        final grossAmount =
            (data['grossAmount'] as num?)?.toInt(); // Ambil dari data WebSocket
        final bank = data['bank'] as String?;
        final vaNumber = data['vaNumber'] as String?;

        // Pastikan orderId sesuai sebelum update
        if (receivedOrderId == _lastPaymentDetails?.orderId) {
          handleStatusUpdate(receivedOrderId, status, paymentType, grossAmount,
              bank, vaNumber);
        }
      }
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket disconnected');
    });

    _socket!.onError((error) {
      print('❗ Socket error: $error');
    });
  }

  /// Tangani update status dari WebSocket
  void handleStatusUpdate(
    String orderId,
    String status,
    String? paymentType, // <-- Tambahkan parameter
    int? grossAmount, // <-- Tambahkan parameter
    String? bank, // <-- Tambahkan parameter
    String? vaNumber, // <-- Tambahkan parameter
  ) {
    if (kDebugMode) {
      print('handleStatusUpdate() -> OrderId: $orderId, Status: $status');
    }

    // Gunakan detail pembayaran yang tersimpan sebelumnya
    final currentDetails = _lastPaymentDetails;

    if (currentDetails != null) {
      final updatedPayment = PaymentSuccessModel(
        orderId: orderId,
        grossAmount: grossAmount ??
            currentDetails.grossAmount, // Gunakan yang baru atau yang tersimpan
        transactionStatus: status,
        paymentType: paymentType ??
            currentDetails.paymentType, // Gunakan yang baru atau yang tersimpan
        bank: bank ?? currentDetails.bank,
        vaNumber: vaNumber ?? currentDetails.vaNumber,
      );
      emit(PaymentSuccess(updatedPayment));
      _lastPaymentDetails = updatedPayment; // Perbarui detail terakhir
    } else {
      // Jika _lastPaymentDetails null (misal karena refresh aplikasi),
      // maka buat PaymentSuccessModel baru dengan data yang ada.
      // Idealnya, state awal harus selalu memiliki detail transaksi.
      final updatedPayment = PaymentSuccessModel(
        orderId: orderId,
        grossAmount: grossAmount ?? 0, // Fallback jika tidak ada data awal
        transactionStatus: status,
        paymentType: paymentType ?? 'unknown', // Fallback
        bank: bank,
        vaNumber: vaNumber,
      );
      emit(PaymentSuccess(updatedPayment));
      _lastPaymentDetails = updatedPayment;
    }
  }

  /// Matikan koneksi saat tidak digunakan
  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket?.destroy();
    _lastPaymentDetails = null; // Bersihkan detail terakhir
    return super.close();
  }

  /// Reset state cubit (misal setelah transaksi selesai)
  void resetState() {
    emit(const PaymentInitial());
    _lastPaymentDetails = null;
  }
}
