// import 'package:flutter/material.dart';
// import 'package:getsayor/presentation/pages/top_up/components/invoice_page.dart';
// import 'package:intl/intl.dart';

// class ConfirmationModal extends StatelessWidget {
//   final int selectedPoints;
//   final int totalPrice;

//   const ConfirmationModal({
//     super.key,
//     required this.selectedPoints,
//     required this.totalPrice,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final numberFormat = NumberFormat("#,##0", "id_ID");

//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         // Konten Modal Bottom Sheet
//         FractionallySizedBox(
//           widthFactor: 1.0,
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 50,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Top Up',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 16,
//                     color: Color(0xFF1F2131),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Top Up Amount",
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         color: Colors.grey,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Image.asset(
//                           'assets/images/poin_cs.png',
//                           width: 16,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '$selectedPoints ',
//                           style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             color: Color(0xFF1F2131),
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 const Divider(color: Color(0xFFE2E3E6), thickness: 1),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Payment Amount",
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         color: Colors.grey,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       'Rp. ${numberFormat.format(totalPrice)}',
//                       style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         color: Color(0xFF1F2131),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 const Divider(color: Color(0xFFE2E3E6), thickness: 1),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Date",
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         color: Colors.grey,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('d MMMM, yyyy - hh:mm a')
//                           .format(DateTime.now()),
//                       style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         color: Color(0xFF1F2131),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 const Divider(color: Color(0xFFE2E3E6), thickness: 1),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Tutup dialog
//                     // Navigasi ke halaman invoice
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => InvoicePage(
//                           points: selectedPoints,
//                           price: totalPrice,
//                           date: DateTime.now(),
//                           bankName: "BCA",
//                           noHp: "+62 896 7375 1717",
//                           email: "contact@carisayor.co.id",
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF74B11A),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text(
//                     'Confirm',
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
