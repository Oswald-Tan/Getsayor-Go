// import 'package:getsayor/data/model/poin_model.dart';
// import 'package:getsayor/data/services/poin_service.dart';
// import 'package:getsayor/presentation/pages/home_test/components/history.dart';
// import 'package:getsayor/presentation/pages/home_test/components/carousel.dart';
// import 'package:flutter/material.dart';
// import 'package:getsayor/presentation/pages/home_test/components/home_header.dart';
// import 'package:getsayor/presentation/pages/home_test/components/shimmer_discount_topup.dart';
// import 'package:getsayor/presentation/pages/top_up/topup_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:getsayor/presentation/providers/user_provider.dart';
// import 'package:intl/intl.dart';

// class HomeScreenTest extends StatefulWidget {
//   static String routeName = "/home";

//   const HomeScreenTest({super.key});

//   @override
//   State<HomeScreenTest> createState() => _HomeScreenTestState();
// }

// class _HomeScreenTestState extends State<HomeScreenTest> {
//   final GlobalKey<RiwayatScreenState> riwayatKey = GlobalKey();
//   List<Poin> discountedPoins = [];
//   bool isLoadingPoins = false;
//   String message = "";

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final arguments = ModalRoute.of(context)!.settings.arguments;

//     if (arguments != null) {
//       Map? pushArguments = arguments as Map;

//       setState(() {
//         message = pushArguments['message'];
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchDiscountedPoins();
//   }

//   Future<void> _fetchDiscountedPoins() async {
//     setState(() => isLoadingPoins = true);
//     try {
//       PoinService poinService = PoinService();
//       List<Poin> poinList = await poinService.fetchPoin(context);
//       List<Poin> discounted = poinList
//           .where((poin) =>
//               poin.discountPercentage != null && poin.discountPercentage! > 0)
//           .toList();
//       setState(() => discountedPoins = discounted);
//     } catch (e) {
//       debugPrint("Error fetching discounted poins: $e");
//     } finally {
//       setState(() => isLoadingPoins = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     final userProvider = Provider.of<UserProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         automaticallyImplyLeading: false,
//         toolbarHeight: 80,
//         backgroundColor: Colors.white,
//         title: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Getsayor',
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black,
//                     ),
//                   ),
//                   Consumer<UserProvider>(
//                     builder: (context, userProvider, child) {
//                       final fullname = userProvider.fullname ?? 'User';
//                       return Text(
//                         'Hi, $fullname!',
//                         style: const TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 12,
//                           color: Colors.black,
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.asset(
//                   color: Colors.black,
//                   'assets/images/cs.png',
//                   width: 25,
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await riwayatKey.currentState?.refreshData();
//             userProvider.getUserData(userProvider.token!);
//             await _fetchDiscountedPoins();
//           },
//           color: const Color(0xFF74B11A),
//           backgroundColor: Colors.white,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(vertical: 0),
//             child: Column(
//               children: [
//                 const SizedBox(
//                   height: 170,
//                   child: Header(),
//                 ),
//                 const SizedBox(height: 20),

//                 // Container untuk konten utama
//                 Container(
//                   width: screenWidth,
//                   height: 312,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFF0F1F5),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 10),
//                       Expanded(
//                         child: RiwayatScreen(key: riwayatKey),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 if (isLoadingPoins)
//                   const ShimmerCarousel()
//                 else if (discountedPoins.isNotEmpty)
//                   DiscountedPoinCarousel(
//                     discountedPoins: discountedPoins,
//                     onTap: (poin) {
//                       Navigator.pushNamed(
//                         context,
//                         TopUpPage.routeName,
//                         arguments: poin.id,
//                       );
//                     },
//                   ),

//                 const SizedBox(height: 0),

//                 // CategoriesCarousel muncul setelah BahanCard
//                 const CategoriesCarousel(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DiscountedPoinCarousel extends StatelessWidget {
//   final List<Poin> discountedPoins;
//   final Function(Poin) onTap;

//   const DiscountedPoinCarousel({
//     super.key,
//     required this.discountedPoins,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final numberFormat = NumberFormat("#,##0", "id_ID");

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(left: 20, bottom: 10),
//           child: Text(
//             "Promo Spesial Top Up",
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1F2131),
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 140,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             decoration: const BoxDecoration(
//               color: Color(0xFF74B11A),
//               image: DecorationImage(
//                 image: AssetImage('assets/images/grid.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               clipBehavior: Clip.none, // Mencegah pemotongan shadow
//               itemCount: discountedPoins.length,
//               separatorBuilder: (context, index) => const SizedBox(width: 15),
//               itemBuilder: (context, index) {
//                 Poin poin = discountedPoins[index];
//                 return GestureDetector(
//                   onTap: () => onTap(poin),
//                   child: Container(
//                     width: 200,
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           spreadRadius: 2,
//                           offset: const Offset(2, 2),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Image.asset(
//                                 'assets/images/poin_cs.png',
//                                 width: 18,
//                               ),
//                               const SizedBox(width: 4),
//                               Text('${poin.poin}',
//                                   style: const TextStyle(
//                                     fontFamily: 'Poppins',
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w700,
//                                   )),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               if (poin.originalPrice != null)
//                                 Text(
//                                   'Rp. ${numberFormat.format(poin.originalPrice)}',
//                                   style: const TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 14,
//                                     decoration: TextDecoration.lineThrough,
//                                   ),
//                                 ),
//                               Text(
//                                 'Rp. ${numberFormat.format(poin.price)}',
//                                 style: const TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Color(0xFF74B11A),
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const Spacer(),
//                               if (poin.discountPercentage != null &&
//                                   poin.discountPercentage! > 0)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 4, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red,
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Icon(
//                                         Icons.discount,
//                                         size: 10,
//                                         color: Colors.white,
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         'Diskon ${poin.discountPercentage!}%',
//                                         style: const TextStyle(
//                                           fontFamily: 'Poppins',
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
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
