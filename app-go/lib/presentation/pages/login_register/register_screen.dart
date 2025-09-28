import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';
import 'package:getsayor/presentation/pages/privacy_policy.dart';
import 'package:getsayor/presentation/pages/terms_of_use.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_no_hp_widget.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_email_widget.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_pass_confirm_widget.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_pass_widget.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_fullname_widget.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_referral_by_widget.dart';
import 'package:getsayor/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = "/register";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController referralBy = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController fullname = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  bool isAgreed = false;
  bool isLoading = false;

  @override
  void dispose() {
    referralBy.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    fullname.dispose();
    phoneNumber.dispose();
    super.dispose();
  }

  void _showErrorModal({
    required BuildContext context,
    required String title,
    required String message,
    required String imagePath,
    VoidCallback? onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Image
              Image.asset(
                imagePath,
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Error Title
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),

              // Error Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),

              // Action Buttons
              Row(
                children: [
                  // Try Again Button
                  if (onRetry != null) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close modal
                          onRetry(); // Retry action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF74B11A),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Close Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Color(0xFF74B11A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF74B11A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _registerUser() async {
    if (!isAgreed) {
      _showErrorModal(
        context: context,
        title: 'Agreement Required',
        message:
            'You must agree to the Privacy Policy and Terms of Use to register.',
        imagePath: 'assets/images/agreement_error.png',
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      _showErrorModal(
        context: context,
        title: 'Password Mismatch',
        message:
            'The passwords you entered do not match. Please re-enter your password.',
        imagePath: 'assets/images/password_error.png',
      );
      return;
    }

    // Validasi referral code wajib diisi
    if (referralBy.text.isEmpty) {
      _showErrorModal(
        context: context,
        title: 'Referral Code Required',
        message: 'Please enter a valid referral code to register.',
        imagePath: 'assets/images/referral_error.png',
      );
      return;
    }

    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final errorMessage = await authProvider.registerUser(
        referralCode: referralBy.text,
        fullname: fullname.text,
        password: password.text,
        email: email.text,
        phoneNumber: phoneNumber.text,
        roleName: 'user',
      );

      if (errorMessage == null) {
        // Registration successful
        Navigator.pop(context);
      } else {
        // Handle API validation errors
        _showErrorModal(
          context: context,
          title: 'Registration Failed',
          message: errorMessage,
          imagePath: 'assets/images/no-internet.png',
        );
      }
    } catch (error) {
      // Handle network/connection errors
      String title;
      String message;
      String imagePath;

      if (error.toString().contains('Connection timeout')) {
        title = 'Connection Timeout';
        message =
            'The connection to the server took too long. Please check your internet connection and try again.';
        imagePath = 'assets/images/no-internet.png';
      } else if (error.toString().contains('network')) {
        title = 'Network Error';
        message =
            'No internet connection. Please check your network settings and try again.';
        imagePath = 'assets/images/no-internet.png';
      } else {
        title = 'Server Error';
        message =
            'An error occurred while processing your registration. Please try again later.';
        imagePath = 'assets/images/no-internet.png';
      }

      _showErrorModal(
        context: context,
        title: title,
        message: message,
        imagePath: imagePath,
        onRetry: _registerUser,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Diubah menjadi true
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(children: [
            // Gambar di bagian kiri atas
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'assets/images/daun1.png',
                fit: BoxFit.contain,
                // width: 10,
                height: 50,
              ),
            ),

            // Gambar di bagian kanan atas
            Positioned(
              top: 160,
              right: 0,
              child: Image.asset(
                'assets/images/daun2.png',
                fit: BoxFit.contain,
                // width: 10,
                height: 50,
              ),
            ),

            Center(
              // Widget utama untuk vertical center
              child: SingleChildScrollView(
                // Agar bisa discroll saat keyboard muncul
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Penting! Agar tidak memenuhi layar
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Teks Sign up dan deskripsi
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Text(
                                'Sign up',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 35,
                                  color: Color(0xFF1F2131),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Segera daftar dan rasakan kemudahan berbelanja\n dengan aplikasi Get Sayor!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextfieldFullnameWidget(controller: fullname),
                        const SizedBox(height: 10),
                        TextfieldEmailWidget(controller: email),
                        const SizedBox(height: 10),
                        TextfieldPhoneNumberWidget(controller: phoneNumber),
                        const SizedBox(height: 10),
                        TextfieldPasswordWidget(controller: password),
                        const SizedBox(height: 10),
                        TextfieldConfirmPasswordWidget(
                            controller: confirmPassword),
                        const SizedBox(height: 10),
                        TextfieldReferralCodeWidget(controller: referralBy),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: const Offset(-6, 0),
                              child: Transform.scale(
                                scale: 0.7,
                                child: Checkbox(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  activeColor: const Color(0XFF74B11A),
                                  checkColor: Colors.white,
                                  side: const BorderSide(color: Colors.grey),
                                  value: isAgreed,
                                  onChanged: (value) {
                                    setState(() {
                                      isAgreed = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF74B11A),
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const PrivacyPolicyScreen()),
                                          );
                                        },
                                    ),
                                    const TextSpan(
                                      text: ' and ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms of Use',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF74B11A),
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const TermsOfUseScreen()),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF74B11A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Sudah punya akun? ",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: "Masuk",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Color(0XFF74B11A),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const LoginScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 1.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
                                            var offsetAnimation =
                                                animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
