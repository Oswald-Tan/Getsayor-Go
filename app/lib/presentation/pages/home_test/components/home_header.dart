// import 'package:getsayor/presentation/pages/home_test/components/card_saldo.dart';
// import 'package:flutter/material.dart';

// class Header extends StatelessWidget {
//   const Header({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           ClipPath(
//             clipper: ClipPathClass(),
//             child: Container(
//               height: 135,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(
//             child: CardSaldo(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ClipInfoClass extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height);
//     path.lineTo(size.width - 80, size.height);
//     path.lineTo(size.width, size.height - 80);
//     path.lineTo(size.width, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }

// class ClipPathClass extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height - 60);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height,
//       size.width,
//       size.height - 60,
//     );
//     path.lineTo(size.width, 0);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }
