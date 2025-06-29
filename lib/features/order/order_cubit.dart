// lib/features/order/order_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import './order_remote_datasource.dart';

// --- States ---
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderCreated extends OrderState {
  final String orderId;

  const OrderCreated(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---
class OrderCubit extends Cubit<OrderState> {
  final OrderRemoteDatasource datasource;

  OrderCubit(this.datasource) : super(const OrderInitial());

  // Diperbarui: Tambahkan parameter shippingAddress dan paymentMethod
  Future<void> createOrderFromCart({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    emit(const OrderLoading());
    try {
      if (kDebugMode) print('OrderCubit: Creating order...');
      final orderId = await datasource.createOrderFromCart(
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );
      if (kDebugMode) print('Order created with ID: $orderId');
      emit(OrderCreated(orderId));
    } catch (e) {
      if (kDebugMode) print('Error in OrderCubit: $e');
      emit(OrderError('Gagal membuat order: $e'));
    }
  }

  void resetState() {
    emit(const OrderInitial());
  }
}
