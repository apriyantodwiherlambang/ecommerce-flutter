// lib/features/payment/payment_success_model.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Tambahkan ini untuk debugPrint

class PaymentSuccessModel extends Equatable {
  final String orderId;
  final int grossAmount;
  final String transactionStatus; // Ex: 'pending', 'settlement', 'deny'
  final String paymentType; // Ex: 'bank_transfer', 'gopay'
  final String? bank; // Ex: 'bca', 'bri' if paymentType is bank_transfer
  final String? vaNumber; // Virtual Account number

  const PaymentSuccessModel({
    required this.orderId,
    required this.grossAmount,
    required this.transactionStatus,
    required this.paymentType,
    this.bank,
    this.vaNumber,
  });

  factory PaymentSuccessModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('DEBUG: Inside PaymentSuccessModel.fromJson');
      print('  Raw JSON received: $json');
      print('  gross_amount type: ${json['gross_amount']?.runtimeType}');
      print('  gross_amount value: ${json['gross_amount']}');
    }

    final vaNumbers = json['va_numbers'] as List?;
    final firstVa = (vaNumbers != null && vaNumbers.isNotEmpty)
        ? vaNumbers[0] as Map<String, dynamic>?
        : null;

    // --- PERBAIKAN DI SINI: HAPUS 'final' DARI 'parsedGrossAmount' ---
    int parsedGrossAmount; // Deklarasikan tanpa 'final'

    if (json['gross_amount'] is num) {
      parsedGrossAmount = (json['gross_amount'] as num).toInt();
    } else if (json['gross_amount'] is String) {
      // Coba parse string jika ternyata dikirim sebagai string "200.00"
      try {
        parsedGrossAmount = (double.parse(json['gross_amount'])).toInt();
      } catch (e) {
        if (kDebugMode) print('Error parsing gross_amount string: $e');
        parsedGrossAmount = 0;
      }
    } else {
      parsedGrossAmount = 0; // Default jika bukan num atau string
    }

    if (kDebugMode) {
      print('  Parsed grossAmount: $parsedGrossAmount');
      print('  Parsed orderId: ${json['order_id']}');
      print('  Parsed transactionStatus: ${json['transaction_status']}');
      print('  Parsed paymentType: ${json['payment_type']}');
    }

    return PaymentSuccessModel(
      orderId: json['order_id'] as String? ?? '',
      grossAmount: parsedGrossAmount,
      transactionStatus: json['transaction_status'] as String? ?? 'unknown',
      paymentType: json['payment_type'] as String? ?? 'unknown',
      bank: firstVa != null && firstVa['bank'] != null
          ? firstVa['bank'].toString()
          : null,
      vaNumber: firstVa != null && firstVa['va_number'] != null
          ? firstVa['va_number'].toString()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        grossAmount,
        transactionStatus,
        paymentType,
        bank,
        vaNumber,
      ];
}
