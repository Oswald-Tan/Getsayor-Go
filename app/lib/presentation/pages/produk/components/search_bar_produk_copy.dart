import 'package:flutter/material.dart';

class SearchBarProdukCopy extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onCartPressed;
  final int cartItemCount;

  const SearchBarProdukCopy({
    super.key,
    required this.onSearchChanged,
    required this.onCartPressed,
    required this.cartItemCount, // Menambahkan parameter jumlah item
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: const TextStyle(
                      fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  suffixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Colors.grey,
                  ),
                  contentPadding:
                      const EdgeInsets.only(left: 20, top: 12, bottom: 12),
                ),
              ),
            ),
          ),
          // Cart Icon with Badge
          Container(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Stack(
              clipBehavior: Clip.none, // Agar badge tidak terpotong
              children: [
                IconButton(
                  onPressed:
                      onCartPressed, // Menghubungkan ikon dengan fungsi keranjang
                  icon: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFF0F1F5),
                    child: Icon(Icons.shopping_cart, color: Colors.black),
                  ),
                ),
                // Badge yang muncul jika ada item di cart
                if (cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
