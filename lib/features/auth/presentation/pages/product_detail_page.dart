import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/cart_page.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import '../../../cart/cart_model.dart' as model;

class ProductDetailPage extends StatelessWidget {
  final dynamic product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl ?? '';
    final name = product.name ?? 'No Name';
    final description =
        product.description ?? 'Deskripsi produk tidak tersedia.';
    final category = product.category?.name ?? 'Kategori tidak tersedia';
    final priceValue = product.price?.toInt() ?? 0;
    final price = "Rp ${priceValue.toString()}";

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: Text(name, style: const TextStyle(color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state is CartLoaded) {
                        final items = state.items;
                        if (items.isEmpty) return const SizedBox.shrink();
                        return Text(
                          '${items.length}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "$name\n$description",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(category, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(price,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Center(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  )
                : const Icon(Icons.image_not_supported, size: 100),
          ),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () {}, child: const Text("Read More")),
          ),
          const SizedBox(height: 16),
          Row(children: [
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.favorite_border)),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<CartCubit>().addToCart(product.id, 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text("Tambah Ke Keranjang"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
