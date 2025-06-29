// 15 jun v2
import 'package:flutter/material.dart';
import 'package:frontend_ecommerce/features/payment/payment_success_model.dart';
import 'package:frontend_ecommerce/features/payment/payment_websocket_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final PaymentSuccessModel paymentDetails;

  const PaymentSuccessScreen({super.key, required this.paymentDetails});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  final PaymentWebSocketService _webSocketService = PaymentWebSocketService();
  String _currentStatus = 'Pending';

  @override
  void initState() {
    super.initState();

    // Set status awal dari data
    final status = widget.paymentDetails.transactionStatus.toLowerCase();
    _currentStatus = status;

    // Tangani error koneksi WebSocket
    _webSocketService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Koneksi WebSocket gagal. Silakan periksa koneksi Anda.'),
          ),
        );
      }
    };

    // Tangani update status pembayaran dari WebSocket
    _webSocketService.onPaymentStatusUpdate = (data) {
      final String receivedOrderId = data['orderId'];
      final String receivedStatus = data['status'].toLowerCase();
      print(
          'onPaymentStatusUpdate: OrderID=$receivedOrderId, Status=$receivedStatus');

      if (receivedOrderId == widget.paymentDetails.orderId) {
        if (_currentStatus != receivedStatus) {
          print('Status updated: $_currentStatus → $receivedStatus');
          setState(() {
            _currentStatus = receivedStatus;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Status pembayaran diperbarui: $_currentStatus'),
                  duration: const Duration(seconds: 10),
                ),
              );
            }
          });
        }
      }
    };

    _webSocketService.connect(joinOrderId: widget.paymentDetails.orderId);
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  // Helpers
  String getTitleFromStatus(String status) {
    switch (status) {
      case 'paid':
      case 'settlement':
      case 'capture':
        return 'Pembayaran Berhasil!';
      case 'pending':
        return 'Pembayaran Menunggu Konfirmasi...';
      case 'cancel':
      case 'expire':
      case 'deny':
        return 'Pembayaran Gagal/Dibatalkan';
      case 'failed': // Untuk status 'Failed' dari backend
        return 'Pembayaran Gagal';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  String getDescriptionFromStatus(String status) {
    switch (status) {
      case 'paid':
      case 'settlement':
      case 'capture':
        return 'Produk akan segera kami kirim setelah pembayaran dikonfirmasi.';
      case 'pending':
        return 'Harap selesaikan pembayaran Anda. Status akan diperbarui secara otomatis.';
      case 'cancel':
      case 'expire':
      case 'deny':
        return 'Ada masalah dengan pembayaran Anda. Mohon coba lagi atau hubungi dukungan.';
      case 'failed': // Untuk status 'Failed' dari backend
        return 'Pembayaran Gagal';
      default:
        return 'Status tidak dikenali.';
    }
  }

  IconData getIconFromStatus(String status) {
    switch (status) {
      case 'paid':
      case 'settlement':
      case 'capture':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'cancel':
      case 'expire':
      case 'deny':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color getColorFromStatus(String status) {
    switch (status) {
      case 'paid':
      case 'settlement':
      case 'capture':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancel':
      case 'expire':
      case 'deny':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatPrice(int price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = getColorFromStatus(_currentStatus);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                getIconFromStatus(_currentStatus),
                color: color,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                getTitleFromStatus(_currentStatus),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                getDescriptionFromStatus(_currentStatus),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildDetailRow(
                          'Order ID', widget.paymentDetails.orderId),
                      _buildDetailRow('Total Pembayaran',
                          _formatPrice(widget.paymentDetails.grossAmount)),
                      _buildDetailRow('Status', _currentStatus),
                      _buildDetailRow('Metode Pembayaran',
                          widget.paymentDetails.paymentType),
                      if (widget.paymentDetails.bank != null)
                        _buildDetailRow('Bank', widget.paymentDetails.bank!),
                      if (widget.paymentDetails.vaNumber != null)
                        _buildDetailRow(
                            'Virtual Account', widget.paymentDetails.vaNumber!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _currentStatus == 'pending'
                      ? null
                      : () => Navigator.of(context)
                          .pushReplacementNamed('/notification-page'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke halaman utama',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
