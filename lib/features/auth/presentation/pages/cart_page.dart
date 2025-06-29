//#4
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import 'package:frontend_ecommerce/features/order/order_cubit.dart';
import 'package:frontend_ecommerce/features/payment/payment_cubit.dart';
import 'package:frontend_ecommerce/features/payment/payment_success_screen.dart';
import 'package:frontend_ecommerce/features/payment/payment_success_model.dart';
import '../../../cart/cart_model.dart' as model;

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('Keranjang kosong'));
            }

            int subtotal = 0;
            for (var item in items) {
              subtotal += item.price * item.quantity;
            }

            const int shippingCost = 10000;
            final int totalAmount = subtotal + shippingCost;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CartItemCard(item: item);
                    },
                  ),
                ),
                _OrderSummary(
                  subtotal: subtotal,
                  shippingCost: shippingCost,
                  totalAmount: totalAmount,
                ),
                _CheckoutButton(
                  subtotal: subtotal,
                  shippingCost: shippingCost,
                  totalAmount: totalAmount,
                  cartItems: items,
                ),
              ],
            );
          } else if (state is CartError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Keranjang kosong'));
          }
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final model.CartItemModel item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    String formattedPrice =
        'Rp ${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey),
                      )
                    : const Icon(Icons.image_not_supported,
                        size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (item.quantity > 1) {
                            context
                                .read<CartCubit>()
                                .updateQuantity(item.id, item.quantity - 1);
                          } else {
                            context.read<CartCubit>().removeItem(item.id);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: () {
                          context
                              .read<CartCubit>()
                              .updateQuantity(item.id, item.quantity + 1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final int subtotal;
  final int shippingCost;
  final int totalAmount;

  const _OrderSummary({
    required this.subtotal,
    required this.shippingCost,
    required this.totalAmount,
  });

  String _formatPrice(int price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(_formatPrice(subtotal),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ongkos Kirim',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(_formatPrice(shippingCost),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Semua',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                _formatPrice(totalAmount),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget untuk tombol Checkout (DIUPDATE SECARA SIGNIFIKAN)
class _CheckoutButton extends StatelessWidget {
  final int subtotal;
  final int shippingCost;
  final int totalAmount;
  final List<model.CartItemModel> cartItems;

  const _CheckoutButton({
    required this.subtotal,
    required this.shippingCost,
    required this.totalAmount,
    required this.cartItems,
  });

  String _formatPrice(int price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OrderCubit, OrderState>(
          listener: (context, orderState) {
            if (orderState is OrderLoading) {
              print('OrderCubit: Creating order...');
            } else if (orderState is OrderCreated) {
              print(
                  'OrderCubit: Order created with ID: ${orderState.orderId}. Now creating payment...');
              context.read<PaymentCubit>().createPayment(
                orderState.orderId,
                totalAmount,
                [],
              );
              context.read<OrderCubit>().resetState();
            } else if (orderState is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Error membuat order: ${orderState.message}')),
              );
              context.read<OrderCubit>().resetState();
            }
          },
        ),
        BlocListener<PaymentCubit, PaymentState>(
          listener: (context, paymentState) {
            if (paymentState is PaymentLoading) {
              print('PaymentCubit: Processing payment...');
            } else if (paymentState is PaymentSuccess) {
              print(
                  'PaymentCubit: Payment processed successfully. Navigating to success screen.');
              Navigator.of(context).pushReplacementNamed(
                '/payment-success',
                arguments: paymentState.paymentDetails,
              );
              context.read<CartCubit>().clearCart();
              context.read<PaymentCubit>().resetState();
            } else if (paymentState is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error pembayaran: ${paymentState.message}')),
              );
              context.read<PaymentCubit>().resetState();
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) {
              final paymentState = context.watch<PaymentCubit>().state;
              final bool isLoading =
                  orderState is OrderLoading || paymentState is PaymentLoading;

              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // --- Contoh Nilai Dummy ---
                        // GANTI ini dengan input aktual dari UI Anda (misal: dari TextField, Dropdown, dll.)
                        final String shippingAddress =
                            'Jl. Contoh No. 123, Kota Dummy, 12345';
                        final String paymentMethod =
                            'Bank Transfer'; // Atau 'Credit Card', 'Cash On Delivery'

                        context.read<OrderCubit>().createOrderFromCart(
                              shippingAddress: shippingAddress,
                              paymentMethod: paymentMethod,
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Checkout',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
