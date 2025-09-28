import 'package:flutter/material.dart';

class SearchBarProduk extends StatelessWidget {
  final Function(String) onSearchChanged;
  // final VoidCallback onCartPressed;
  // final int cartItemCount;

  const SearchBarProduk({
    super.key,
    required this.onSearchChanged,
    // required this.onCartPressed,
    // required this.cartItemCount, // Menambahkan parameter jumlah item
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
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 10, top: 0),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE9E9E9),
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

                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 22,
                    ),
                  ), //
                  contentPadding: const EdgeInsets.only(
                      left: 20, right: 20, top: 14, bottom: 14),
                ),
              ),
            ),
          ),
          // Cart Icon with Badge
          // Container(
          //   padding: const EdgeInsets.only(right: 10, top: 10),
          //   child: Stack(
          //     clipBehavior: Clip.none, // Agar badge tidak terpotong
          //     children: [
          //       IconButton(
          //         onPressed:
          //             onCartPressed, // Menghubungkan ikon dengan fungsi keranjang
          //         icon: const CircleAvatar(
          //           radius: 25,
          //           backgroundColor: Color(0xFFF0F1F5),
          //           child: Icon(Icons.shopping_cart, color: Colors.black),
          //         ),
          //       ),
          //       Badge yang muncul jika ada item di cart
          //       if (cartItemCount > 0)
          //         Positioned(
          //           right: 0,
          //           top: 0,
          //           child: CircleAvatar(
          //             radius: 10,
          //             backgroundColor: Colors.red,
          //             child: Text(
          //               '$cartItemCount',
          //               style: const TextStyle(
          //                 fontFamily: 'Poppins',
          //                 fontSize: 8,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ),
          //         ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
