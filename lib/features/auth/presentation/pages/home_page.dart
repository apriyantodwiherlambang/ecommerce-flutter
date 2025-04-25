import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryFilter(),
              const SizedBox(height: 24),
              _buildSectionTitle("Jaket Outdoor Second Like New"),
              const SizedBox(height: 24),
              _buildProductListHorizontal(),
              const SizedBox(height: 24),
              _buildSectionTitle("Sepatunya Gen-Z"),
              const SizedBox(height: 24),
              _buildProductListVertical(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Image.asset(
          'assets/hamburger.png',
          height: 24,
          width: 24,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Menjaga posisi di tengah
        children: [
          // Menambahkan gambar highlight_tokas di sebelah kiri atas teks "TOKAS"
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/highlight_tokas.png',
                height: 14, // Sesuaikan ukuran gambar
                width: 14, // Sesuaikan ukuran gambar
              ),
              Positioned(
                top: 4, // Menyesuaikan posisi vertikal gambar highlight
                right: -30, // Menggeser lebih ke kiri
                child: Text(
                  "TOKAS",
                  style: TextStyle(
                    color: Color.fromARGB(255, 98, 88, 88),
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Ukuran font lebih kecil
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true, // Memastikan judul tetap di tengah
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8.0), // Menurunkan ikon tas manual
            child: Image.asset(
              'assets/bag2.png',
              height: 24,
              width: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari barang thrifting kesukaanmu...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Semua', 'Jaket', 'Topi', 'Sepatu', 'Baju', 'Tas'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == 'Semua';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) {},
              selectedColor: Colors.black,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              shape: const StadiumBorder(
                side: BorderSide(color: Colors.black12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Lihat semua",
          style: TextStyle(color: Color(0xFF0D6EFD)),
        ),
      ],
    );
  }

  Widget _buildProductListHorizontal() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.transparent,
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/shoes.png',
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Jaket National...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Jaket Pria",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Rp.300.000",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_circle_right,
                          color: Color(0xFF0D6EFD),
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductListVertical() {
    return Column(
      children: List.generate(5, (index) {
        return Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/shoes.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Air Jordan 1 Mid SE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Sepatu Unisex",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              const Text(
                                "5.0",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Text(
                                "Rp.500.000",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "15% OFF",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.favorite_border,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      SizedBox(height: 47),
                      Icon(
                        Icons.arrow_circle_right,
                        color: Color(0xFF0D6EFD),
                        size: 28,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
