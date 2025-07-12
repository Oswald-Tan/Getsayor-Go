import 'package:getsayor/presentation/pages/favorite/favorite_screen.dart';
import 'package:getsayor/presentation/pages/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/produk/components/order_page.dart';
import 'package:getsayor/presentation/pages/profile/profile_screen.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

const Gradient inActiveIconGradient = LinearGradient(
  colors: [Color(0xFFB4B4B4), Color(0xFF888888)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class InitScreen extends StatefulWidget {
  static String routeName = "/init";

  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int currentSelectedIndex = 0;

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get user provider here in the build method
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    // Define pages inside build method where context is available
    final pages = [
      const HomeScreen(),
      OrderPage(userId: userId ?? 0),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Content Pages
          IndexedStack(
            index: currentSelectedIndex,
            children: pages,
          ),
          // Floating Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(3, 0),
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(0)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildFloatingIconButton(FontAwesomeIcons.house, 'Home', 0),
                  buildFloatingIconButton(
                      FontAwesomeIcons.clipboardList, 'Order', 1),
                  buildFloatingIconButton(
                      FontAwesomeIcons.solidHeart, 'Favorite', 2),
                  buildFloatingIconButton(
                      FontAwesomeIcons.solidUser, 'Profile', 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFloatingIconButton(IconData icon, String label, int index) {
    bool isSelected = currentSelectedIndex == index;

    return GestureDetector(
      onTap: () {
        updateCurrentIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds)
                  : inActiveIconGradient.createShader(bounds),
              child: FaIcon(
                icon,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds)
                  : inActiveIconGradient.createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
