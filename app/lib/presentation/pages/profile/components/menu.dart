import 'package:getsayor/data/services/bank_account_service.dart';
import 'package:getsayor/presentation/pages/bonus/rewards_page.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';
import 'package:getsayor/presentation/pages/privacy_policy.dart';
import 'package:getsayor/presentation/pages/profile/components/alamat_saya.dart';
import 'package:getsayor/presentation/pages/profile/components/bank_account.dart';
import 'package:getsayor/presentation/pages/profile/components/edit_profile.dart';
import 'package:getsayor/presentation/pages/terms_of_use.dart';
import 'package:getsayor/presentation/pages/top_up/components/poin_page.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getsayor/data/services/address_service.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
  });

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _addressCount = 0;
  bool _isLoadingAddress = true;
  bool _hasBankAccount = false;
  bool _isLoadingBankAccount = true;

  Future<void> _logout() async {
    try {
      // Gunakan AuthProvider untuk melakukan logout
      await Provider.of<AuthProvider>(context, listen: false).logout();
      Fluttertoast.showToast(
        msg: "Logout berhasil",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      // Arahkan pengguna ke halaman LoginScreen setelah logout
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint("Error during logout: $e");
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  String? appVersion;

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint("Error getting app version: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _loadAddressCount();
    _loadBankAccountStatus();
  }

  Future<void> _loadAddressCount() async {
    try {
      setState(() => _isLoadingAddress = true);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId != null) {
        final addresses =
            await AddressService().getUserAddresses(context, userId);
        setState(() => _addressCount = addresses.length);
      }
    } catch (e) {
      debugPrint("Error loading address count: $e");
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _loadBankAccountStatus() async {
    try {
      final hasAccount = await BankAccountService().hasBankAccount(context);
      setState(() => _hasBankAccount = hasAccount);
    } catch (e) {
      debugPrint("Error loading bank account status: $e");
      setState(() => _hasBankAccount = false);
    } finally {
      setState(() => _isLoadingBankAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // APP SETTINGS
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "AKUN",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black54,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Divider(color: Color(0x3BB0B0B0)),

              // Profile Menu Item
              _buildMenuItem(
                icon: FontAwesomeIcons.solidUser,
                title: "Profil Saya",
                subtitle: "Ubah data profil Anda",
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const EditProfileScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),

              // Address Menu Item - TAMBAHKAN BADGE DI SINI
              _buildMenuItem(
                icon: FontAwesomeIcons.locationDot,
                title: "Alamat Saya",
                subtitle: "Kelola alamat pengiriman",
                showBadge: _addressCount == 0 && !_isLoadingAddress,
                badgeText: "Lengkapi Data",
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddressPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  // Refresh count setelah kembali dari address page
                  _loadAddressCount();
                },
              ),

              // Bank Account Menu Item
              _buildMenuItem(
                icon: FontAwesomeIcons.buildingColumns,
                title: "No Rekening",
                subtitle: "Kelola rekening bank Anda",
                showBadge: !_hasBankAccount && !_isLoadingBankAccount,
                badgeText: "Lengkapi Data",
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const BankAccountPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  // Refresh bank account status after returning
                  _loadBankAccountStatus();
                },
              ),

              const SizedBox(height: 16),

              // FEATURES SECTION
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "FITUR",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black54,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Divider(color: Color(0x3BB0B0B0)),

              // Rewards Menu Item
              _buildMenuItem(
                icon: FontAwesomeIcons.gift,
                title: "Reward",
                subtitle: "Lihat reward yang tersedia",
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const RewardsPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),

              // Points Menu Item
              _buildMenuItem(
                icon: FontAwesomeIcons.coins,
                title: "Point",
                subtitle: "Cek poin dan riwayat",
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PoinPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SETTINGS SECTION
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PENGATURAN",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black54,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Divider(color: Color(0x3BB0B0B0)),

              // Privacy Policy Menu Item
              _buildMenuItem(
                icon: FontAwesomeIcons.lock,
                title: "Privacy Policy",
                subtitle: "Kebijakan privasi aplikasi",
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PrivacyPolicyScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),

              // Terms of Use Menu Item
              _buildMenuItem(
                icon: FontAwesomeIcons.solidFileLines,
                title: "Terms of Use",
                subtitle: "Syarat dan ketentuan penggunaan",
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const TermsOfUseScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20), // Sudut membulat
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Judul dialog
                                  const Text(
                                    'Konfirmasi Logout',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Konten dialog
                                  const Text(
                                    'Apakah Anda yakin ingin logout?',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),

                                  // Tombol Batal
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Tutup dialog
                                    },
                                    child: Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Tombol Logout
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _logout();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8EC61D),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                    ),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Log out",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  appVersion != null ? "Versi $appVersion" : "Tidak Diketahui",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom menu item widget
Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  bool showBadge = false,
  String badgeText = "",
}) {
  return InkWell(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Stack(
              children: [
                FaIcon(
                  icon,
                  size: 16,
                  color: const Color(0xFF404245),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (showBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black54,
            size: 14,
          ),
        ],
      ),
    ),
  );
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback press;
  final Color textColor; // Tambahkan parameter untuk warna teks
  final Color iconColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.press,
    this.textColor = const Color(0xFF1F2131), // Default color
    this.iconColor = const Color(0xFF1F2131),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: press, // Menangani klik tanpa efek tambahan
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: const Color(0xFF404245),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF404245),
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right,
              size: 14,
              color: Color(0xFF404245),
            ),
          ],
        ),
      ),
    );
  }
}
