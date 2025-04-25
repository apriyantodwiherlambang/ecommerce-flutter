import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> items = [
    CartItem('Nike Air Jordan 1', 500000, 'assets/shoes.png'),
    CartItem('Nike Air Jordan 1', 300000, 'assets/shoes.png'),
    CartItem('Nike Air Jordan 1', 300000, 'assets/shoes.png'),
    CartItem('Nike Air Jordan 1', 300000, 'assets/shoes.png'),
    CartItem('Nike Air Jordan 1', 300000, 'assets/shoes.png'),
  ];

  @override
  Widget build(BuildContext context) {
    int subtotal = items.fold(0, (sum, item) => sum + item.price);
    int shipping = 10000;
    int total = subtotal + shipping;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Keranjang"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return CartItemWidget(item: items[index]);
              },
            ),
          ),
          CartSummary(subtotal: subtotal, shipping: shipping, total: total),
        ],
      ),
    );
  }
}

class CartItem {
  final String name;
  final int price;
  final String imagePath;

  CartItem(this.name, this.price, this.imagePath);
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black12),
        ],
      ),
      child: Row(
        children: [
          Image.asset(item.imagePath, width: 80),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                    "Rp.${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.remove),
              ),
              Text('1', style: TextStyle(fontSize: 16)),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int total;

  const CartSummary({
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  String _formatCurrency(int value) {
    return "Rp.${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SummaryRow(title: "Subtotal", value: _formatCurrency(subtotal)),
          SummaryRow(title: "Ongkos Kirim", value: _formatCurrency(shipping)),
          Divider(),
          SummaryRow(
            title: "Total Semua",
            value: _formatCurrency(total),
            isTotal: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
              backgroundColor: Color(0xFF0D6EFD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Checkout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;

  const SummaryRow({
    required this.title,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Color(0xFF0D6EFD) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
