// import 'package:flutter/material.dart';
// import 'package:getsayor/presentation/pages/top_up/components/confirmation_modal.dart';
// import 'package:getsayor/presentation/pages/top_up/components/poin_selection.dart';
// import 'package:getsayor/presentation/pages/top_up/components/shimmer_grid.dart';
// import 'package:getsayor/presentation/pages/top_up/components/topinfo_instruction.dart';
// import 'package:getsayor/data/services/poin_service.dart';
// import 'package:getsayor/data/model/poin_model.dart';
// import 'package:collection/collection.dart';

// class TopUpPage extends StatefulWidget {
//   const TopUpPage({super.key});

//   static String routeName = "/topup";

//   @override
//   TopUpPageState createState() => TopUpPageState();
// }

// class TopUpPageState extends State<TopUpPage> {
//   List<Map<String, dynamic>> pointsOptions = [];
//   int selectedPoints = 0;
//   int totalPrice = 0;
//   bool isLoading = true; // State untuk menandakan loading
//   bool _isDataLoaded = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_isDataLoaded) {
//       _loadPoints();
//       _isDataLoaded = true;
//     }
//   }

//   void onSelectPoints(int points, int price) {
//     setState(() {
//       selectedPoints = points;
//       totalPrice = price;
//     });
//   }

//   Future<void> _loadPoints() async {
//     setState(() {
//       isLoading = true; // Set loading state saat mulai fetch data
//     });

//     try {
//       PoinService poinService = PoinService();
//       List<Poin> poinList = await poinService.fetchPoin(context);

//       setState(() {
//         pointsOptions = poinList
//             .map((poin) => {
//                   'points': poin.poin,
//                   'price': poin.price,
//                   'discountPercentage': poin.discountPercentage,
//                   'originalPrice': poin.originalPrice
//                 })
//             .toList();
//       });

//       final int? selectedPoinId =
//           ModalRoute.of(context)?.settings.arguments as int?;
//       if (selectedPoinId != null) {
//         var selectedPoin =
//             poinList.firstWhereOrNull((poin) => poin.id == selectedPoinId);
//         if (selectedPoin != null) {
//           onSelectPoints(selectedPoin.poin, selectedPoin.price ?? 0);
//         }
//       }
//     } catch (e) {
//       debugPrint("Error fetching points: $e");
//     } finally {
//       setState(() {
//         isLoading = false; // Setelah fetch selesai, matikan loading state
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadPoints();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           'Top Up',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF1F2131),
//             fontSize: 16,
//           ),
//         ),
//       ),
//       backgroundColor: const Color(0xFFF0F1F5),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: RefreshIndicator(
//           onRefresh: _loadPoints,
//           color: const Color(0xFF74B11A),
//           backgroundColor: Colors.white,
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const TopUpInfoInstruction(),
//                       const SizedBox(height: 20),

//                       // Menampilkan shimmer saat loading
//                       if (isLoading)
//                         const ShimmerGrid(itemCount: 10)
//                       else if (pointsOptions.isEmpty)
//                         const Center(
//                           child: Text(
//                             'Tidak ada data poin',
//                             style: TextStyle(
//                                 fontFamily: 'Poppins', color: Colors.black54),
//                           ),
//                         )
//                       else
//                         PointsSelection(
//                           pointsOptions: pointsOptions,
//                           selectedPoints: selectedPoints,
//                           onSelectPoints: onSelectPoints,
//                         ),

//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),

//               // Button tetap di bawah
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: selectedPoints > 0
//                       ? () {
//                           showModalBottomSheet(
//                             context: context,
//                             backgroundColor: Colors.white,
//                             builder: (BuildContext context) {
//                               return ConfirmationModal(
//                                 selectedPoints: selectedPoints,
//                                 totalPrice: totalPrice,
//                               );
//                             },
//                             isScrollControlled: true,
//                           );
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF74B11A),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text(
//                     'Proses',
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
