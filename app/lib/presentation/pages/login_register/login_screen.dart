import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/loading_page.dart';
import 'package:getsayor/presentation/pages/login_register/register_screen.dart';
import 'package:getsayor/presentation/pages/reset_password/reset_password.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_email_widget.dart';
import 'package:getsayor/presentation/widget/textfield/textfield_pass_widget.dart';
import 'package:getsayor/presentation/pages/init_screen.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/auth_provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      _showErrorModal(
        context: context,
        title: 'Input Required',
        message: 'Email and password must be filled',
        imagePath: 'assets/images/no-internet.png',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Show loading page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoadingPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      // Login process
      bool isLoggedIn = await authProvider.loginUser(
        email: email.text,
        password: password.text,
        userProvider: userProvider,
      );

      // If login successful
      if (isLoggedIn && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InitScreen()),
        );
      }
    } catch (error) {
      // Close loading page
      if (mounted) Navigator.pop(context);

      setState(() {
        isLoading = false;
      });

      // Handle different error types
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
      } else if (error.toString().contains('Email not found') ||
          error.toString().contains('Invalid password') ||
          error.toString().contains('credentials') ||
          error.toString().contains('Unauthorized')) {
        title = 'Login Failed';
        message =
            'Incorrect email or password. Please check your credentials and try again.';
        imagePath = 'assets/images/no-internet.png';
      } else if (error.toString().contains('not approved')) {
        title = 'Account Not Approved';
        message =
            'Your account is not approved by admin yet. Please contact support.';
        imagePath = 'assets/images/no-internet.png';
      } else {
        title = 'Server Error';
        message =
            'An error occurred while processing your request. Please try again later.';
        imagePath = 'assets/images/no-internet.png';
      }

      _showErrorModal(
        context: context,
        title: title,
        message: message,
        imagePath: imagePath,
      );
    }
  }

  void _showErrorModal({
    required BuildContext context,
    required String title,
    required String message,
    required String imagePath,
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close modal
                        login(); // Retry login
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Gambar di bagian kiri atas
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'assets/images/login3.png',
                fit: BoxFit.contain,
                // width: 10,
                height: 125,
              ),
            ),

            // Gambar di bagian kanan atas
            Positioned(
              top: 110,
              right: 0,
              child: Image.asset(
                'assets/images/login4.png',
                fit: BoxFit.contain,
                // width: 10,
                height: 125,
              ),
            ),

            // Gambar di bagian bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/login2.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),

            // Konten utama
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo/Title at the top center
                        const Column(
                          children: [
                            SizedBox(height: 15),
                            Text(
                              'Log in',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Yuk, masuk ke akunmu dan mulai berbelanja!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Form Fields
                        TextfieldEmailWidget(controller: email),
                        const SizedBox(height: 10),
                        TextfieldPasswordWidget(controller: password),
                        const SizedBox(height: 20),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              text: 'Lupa Password?',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ResetPasswordScreen(),
                                    ),
                                  );
                                },
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF74B11A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Sign Up Link
                        RichText(
                          text: TextSpan(
                            text: "Belum punya akun? ",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: "Daftar disini",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF74B11A),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
