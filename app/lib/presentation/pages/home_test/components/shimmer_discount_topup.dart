// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// class ShimmerCarousel extends StatelessWidget {
//   const ShimmerCarousel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 20, bottom: 10),
//           child: Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: Container(
//               width: 150,
//               height: 20,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 140,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             decoration: const BoxDecoration(
//               color: Color(0xFF74B11A),
//             ),
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               physics: const NeverScrollableScrollPhysics(),
//               clipBehavior: Clip.none,
//               itemCount: 3, // Jumlah placeholder
//               separatorBuilder: (context, index) => const SizedBox(width: 15),
//               itemBuilder: (context, index) {
//                 return Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     width: 200,
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Placeholder untuk poin
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(15),
//                                 child: Container(
//                                   width: 80,
//                                   height: 24,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               // Placeholder untuk harga
//                               const SizedBox(
//                                 width: 100,
//                                 height: 16,
//                                 child: ColoredBox(color: Colors.white),
//                               ),
//                             ],
//                           ),
//                           const Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               // Placeholder untuk diskon
//                               SizedBox(
//                                 width: 60,
//                                 height: 20,
//                                 child: ColoredBox(color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
