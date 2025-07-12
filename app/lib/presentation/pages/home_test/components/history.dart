// import 'package:flutter/material.dart';
// import 'package:getsayor/data/model/top_up_poin_model.dart';
// import 'package:getsayor/data/services/topup_service.dart';
// import 'package:shimmer/shimmer.dart';

// class RiwayatScreen extends StatefulWidget {
//   const RiwayatScreen({super.key});

//   @override
//   RiwayatScreenState createState() => RiwayatScreenState();
// }

// class RiwayatScreenState extends State<RiwayatScreen> {
//   final TopUpPoinService _topUpService = TopUpPoinService();
//   late Future<List<TopUpPoin>> _fetchData;
//   int getApprovedTransactionsCount(List<TopUpPoin> transactions) {
//     return transactions
//         .where((transaction) => transaction.status == 'approved')
//         .length;
//   }

//   @override
//   void initState() {
//     super.initState();
//     refreshData();
//   }

//   // Fungsi untuk memuat ulang data saat di-refresh
//   Future<void> refreshData() async {
//     setState(() {
//       _fetchData = _topUpService.fetchTopUpPoin(context);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<TopUpPoin>>(
//       future: _fetchData,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Ambil jumlah data yang akan ditampilkan (default 3)
//           int itemCount = 3; // Default value
//           if (snapshot.hasData) {
//             itemCount = getApprovedTransactionsCount(snapshot.data!);
//           }

//           // Tampilkan shimmer effect saat loading
//           return ListView.builder(
//             padding: const EdgeInsets.only(top: 35),
//             itemCount: itemCount,
//             itemBuilder: (context, index) {
//               return buildShimmerEffect();
//             },
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Text(
//               '${snapshot.error}',
//               style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
//             ),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/nodata.png',
//                   width: 200,
//                   height: 200,
//                 ),
//                 const SizedBox(height: 0),
//                 const Text(
//                   'Belum ada transaksi.',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         List<TopUpPoin> transactions = snapshot.data!;

//         // Menyaring transaksi dengan status "approved"
//         List<TopUpPoin> approvedTransactions = transactions
//             .where((transaction) => transaction.status == 'approved')
//             .take(3)
//             .toList();

//         if (approvedTransactions.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/nodata.png',
//                   width: 150,
//                   height: 150,
//                 ),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Belum ada transaksi.',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'History',
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                       color: Color(0xFF1F2131),
//                     ),
//                   ),
//                   // GestureDetector(
//                   //   onTap: () {
//                   //     // Navigasi ke halaman Activity (bisa disesuaikan)
//                   //   },
//                   //   child: Text(
//                   //     'See All',
//                   //     style: TextStyle(fontFamily: 'Poppins',
//                   //       fontWeight: FontWeight.w500,
//                   //       fontSize: 12,
//                   //       color: const Color(0xFF828282),
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//             // Menampilkan transaksi yang diambil dari fetchTopUpPoin
//             Column(
//               children: approvedTransactions.map((transaction) {
//                 DateTime transactionDateTime = DateTime.parse(transaction.date);
//                 String formattedDate = _formatDate(transactionDateTime);
//                 String formattedTime = _formatTime(transactionDateTime);
//                 String transactionAmount = transaction.points.toString();

//                 return History(
//                   transactionTitle: 'Top Up',
//                   transactionDate: '$formattedDate - $formattedTime',
//                   transactionAmount: transactionAmount,
//                 );
//               }).toList(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Format tanggal tanpa menggunakan intl
//   String _formatDate(DateTime date) {
//     List<String> months = [
//       'Januari',
//       'Februari',
//       'Maret',
//       'April',
//       'Mei',
//       'Juni',
//       'Juli',
//       'Agustus',
//       'September',
//       'Oktober',
//       'November',
//       'Desember'
//     ];
//     String day = date.day.toString().padLeft(2, '0');
//     String month = months[date.month - 1];
//     String year = date.year.toString();
//     return '$day $month $year';
//   }

//   // Format waktu tanpa menggunakan intl
//   String _formatTime(DateTime date) {
//     String hour = date.hour.toString().padLeft(2, '0');
//     String minute = date.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }
// }

// Widget buildShimmerEffect() {
//   return Container(
//     height: 70,
//     margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey[300]!, // Warna dasar shimmer
//         highlightColor: Colors.grey[100]!, // Warna highlight shimmer
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Container(
//                       width: 30,
//                       height: 30,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Container(
//                         width: 100,
//                         height: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Container(
//                         width: 80,
//                         height: 12,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Container(
//               alignment: Alignment.centerRight,
//               margin: const EdgeInsets.only(right: 20),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Container(
//                       width: 18,
//                       height: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       width: 50,
//                       height: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// class History extends StatelessWidget {
//   final String transactionTitle;
//   final String transactionDate;
//   final String transactionAmount;

//   const History({
//     super.key,
//     required this.transactionTitle,
//     required this.transactionDate,
//     required this.transactionAmount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String iconPath = getTransactionIcon(transactionTitle.toLowerCase());

//     return Container(
//       height: 70,
//       margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Image.asset(
//                   iconPath,
//                   width: 30,
//                   height: 30,
//                   color: const Color(0XFF74B11A),
//                 ),
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Top Up', // Menggunakan nilai dari field title
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: Color(0xFF1F2131),
//                     ),
//                   ),
//                   Text(
//                     transactionDate,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w400,
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Container(
//             alignment: Alignment.centerRight,
//             margin: const EdgeInsets.only(right: 20),
//             child: Row(
//               children: [
//                 Image.asset(
//                   'assets/images/poin_cs.png',
//                   width: 18,
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   transactionAmount,
//                   style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                     color: Color(0xFF1F2131),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String getTransactionIcon(String transactionType) {
//     if (transactionType == 'top up') {
//       return 'assets/images/top_up_history.png';
//     } else if (transactionType == 'expense') {
//       return 'assets/images/send.png'; // Ganti dengan path ikon untuk expense
//     } else {
//       return 'assets/images/expense_history.png'; // Ganti dengan path ikon default
//     }
//   }
// }
