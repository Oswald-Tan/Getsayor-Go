import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/init_screen.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/auth_provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? appVersion;
  bool _isImagePrecached = false;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isImagePrecached) {
      _isImagePrecached = true;

      // Precache gambar setelah dependencies berubah
      precacheImage(
        const AssetImage("assets/images/logo.png"),
        context,
      ).then((_) {
        if (mounted) {
          // Navigate after 2 seconds delay
          Future.delayed(const Duration(seconds: 2), () {
            _navigateToNextScreen();
          });
        }
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      try {
        // Muat data pengguna terbaru
        await userProvider.getUserData(authProvider.token!);
        // Navigasi ke home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InitScreen()),
          );
        }
      } catch (e) {
        // Jika token tidak valid, logout dan ke login
        await authProvider.logout();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } else if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      debugPrint("Error getting app version: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF74B11A),
              Color(0xFF5A8B15),
              Color(0xFF4A7312),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content (centered logo with shadow)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Version info at bottom
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26), // 0.1 * 255 ≈ 26
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withAlpha(51), // 0.2 * 255 ≈ 51
                        width: 1,
                      ),
                    ),
                    child: Text(
                      appVersion != null ? "Versi $appVersion" : "Versi 1.0.0",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Powered by GetSayor',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withAlpha(179), // 0.7 * 255 ≈ 179
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
