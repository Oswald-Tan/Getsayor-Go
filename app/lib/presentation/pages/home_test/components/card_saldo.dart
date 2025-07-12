// // import 'package:app/empty_page.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:getsayor/presentation/pages/activity/activity_screen.dart';
// import 'package:getsayor/presentation/pages/bonus/rewards_page.dart';
// import 'package:getsayor/presentation/pages/top_up/topup_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:getsayor/presentation/providers/user_provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shimmer/shimmer.dart';

// class CardSaldo extends StatefulWidget {
//   const CardSaldo({super.key});

//   @override
//   CardSaldoState createState() => CardSaldoState();
// }

// class CardSaldoState extends State<CardSaldo> {
//   bool isSaldoVisible = false;
//   bool _isImageLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     // Load image dan deteksi ketika sudah siap
//     const image = AssetImage("assets/images/card.jpg");
//     image.resolve(const ImageConfiguration()).addListener(
//       ImageStreamListener(
//         (info, _) {
//           if (mounted) {
//             setState(() {
//               _isImageLoaded = true;
//             });
//           }
//         },
//       ),
//     );
//   }

//   // Future<void> _showHidePoints() async {
//   //   setState(() {
//   //     isSaldoVisible = !isSaldoVisible;
//   //   });
//   // }

//   void _showComingSoonModal() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return FractionallySizedBox(
//           widthFactor: 1.0,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: const Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Coming Soon',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 16,
//                     color: Color(0xFF1F2131),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'This feature will be available in future updates.',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     color: Color(0xFF1F2131),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       isScrollControlled: true,
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       height: 170,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         color: Colors.white,
//       ),
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           width: 80,
//                           height: 10,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           width: 120,
//                           height: 40,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(
//                   4,
//                   (index) => Column(
//                     children: [
//                       Container(
//                         width: 30,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Container(
//                           width: 40,
//                           height: 10,
//                           color: Colors.white,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserProvider>(
//       builder: (context, userProvider, child) {
//         final saldo = userProvider.points ?? 0;

//         return Container(
//           margin: const EdgeInsets.only(top: 0),
//           child: Column(
//             children: [
//               //tampilkan shimmer jika gambar belum dimuat
//               if (!_isImageLoaded) _buildShimmerEffect(),
//               if (_isImageLoaded)
//                 Column(
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 20),
//                       height: 170,
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(25)),
//                         // gradient: const LinearGradient(
//                         //   begin: Alignment.centerLeft, // Mulai dari kiri
//                         //   end: Alignment.centerRight, // Berakhir di kanan
//                         //   colors: [
//                         //     Color(0xFF589400), // Warna hijau
//                         //     Color(0xFF2E7D32), // Warna hijau lebih gelap
//                         //   ],
//                         // ),
//                         image: DecorationImage(
//                           image: const AssetImage(
//                             "assets/images/card.jpg",
//                           ),
//                           fit: BoxFit.cover,
//                           alignment: Alignment.bottomRight,
//                           colorFilter: ColorFilter.mode(
//                             Colors.black.withOpacity(0.05),
//                             BlendMode.srcATop,
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 25, vertical: 20),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   children: [
//                                     // Image.asset(
//                                     //   width: 20,
//                                     //   'assets/images/poin_cs.png',
//                                     // ),
//                                     const SizedBox(width: 8),
//                                     Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const Text(
//                                           'Poin CS Anda',
//                                           style: TextStyle(
//                                             fontFamily: 'Poppins',
//                                             fontSize: 10,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         Row(
//                                           children: [
//                                             Text(
//                                               saldo.toString(),
//                                               style: const TextStyle(
//                                                 fontFamily: 'Poppins',
//                                                 fontSize: 40,
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                             // const SizedBox(width: 3),
//                                             // Baseline(
//                                             //   baseline: 22,
//                                             //   baselineType:
//                                             //       TextBaseline.alphabetic,
//                                             //   child: Text(
//                                             //     "poin",
//                                             //     style: TextStyle(fontFamily: 'Poppins',
//                                             //       fontSize: 10,
//                                             //       color: Colors.white,
//                                             //       fontWeight: FontWeight.w600,
//                                             //     ),
//                                             //   ),
//                                             // ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 40),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 _buildIconWithText(
//                                   FontAwesomeIcons.circlePlus, // Top Up Icon
//                                   'Top Up',
//                                   () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => const TopUpPage(),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 _buildIconWithText(
//                                   FontAwesomeIcons
//                                       .clockRotateLeft, // Top Up Icon
//                                   'History',
//                                   () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => const Activity(),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 _buildIconWithText(
//                                   FontAwesomeIcons.qrcode, // Scan Icon
//                                   'Scan',
//                                   _showComingSoonModal,
//                                   // () {
//                                   //   Navigator.push(
//                                   //     context,
//                                   //     MaterialPageRoute(
//                                   //       builder: (context) => const EmptyPage(),
//                                   //     ),
//                                   //   );
//                                   // },
//                                 ),
//                                 _buildIconWithText(
//                                   FontAwesomeIcons.coins, // Bonus Icon
//                                   'Reward', // Changed 'Bayar' to 'Bonus'
//                                   () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               const RewardsPage()),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildIconWithText(IconData icon, String text, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.white,
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFF70E55A),
//               size: 18,
//             ),
//           ), // Icon with color
//           const SizedBox(height: 5),
//           Text(
//             text,
//             style: const TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 12,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
