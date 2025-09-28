import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static String routeName = "/onboarding";

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Selamat Datang\ndi Getsayor',
      'description':
          'Belanja sayuran segar langsung dari petani lokal dengan harga terbaik dan kualitas terjamin',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Pesan dengan\nMudah',
      'description':
          'Pilih sayuran favoritmu dan pesan dalam hitungan menit dengan interface yang intuitif',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Pengiriman\nCepat & Segar',
      'description':
          'Pesananmu akan diantar segar dan tepat waktu langsung ke depan pintu rumahmu',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_run', false);

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Konten utama
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        title: _onboardingData[index]['title']!,
                        description: _onboardingData[index]['description']!,
                        imagePath: _onboardingData[index]['image']!,
                      );
                    },
                  ),
                ),

                // Bottom section with indicators and button
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Modern page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: _currentPage == index ? 24.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: _currentPage == index
                                  ? const Color(0xFF74B11A)
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Modern action button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _onboardingData.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _completeOnboarding();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _onboardingData.length - 1
                                    ? 'Mulai Berbelanja'
                                    : 'Lanjutkan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (_currentPage <
                                  _onboardingData.length - 1) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_currentPage < _onboardingData.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                ),
                child: Text(
                  'Lewati',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Modern image container with subtle shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imagePath,
                height: 280,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Modern typography with better hierarchy
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
