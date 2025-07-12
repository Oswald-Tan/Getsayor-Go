import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';
import 'package:getsayor/presentation/pages/reset_password/otp_verification_screen.dart';
import 'package:getsayor/data/services/otp_request_service.dart'; // Import service OTP
// import 'package:provider/provider.dart';
// import 'package:app/providers/user_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  static String routeName = "/reset_password";

  const ResetPasswordScreen({super.key});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false; // Tambahkan state loading

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      Fluttertoast.showToast(msg: "Masukkan email yang valid!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await OTPRequestService().requestOtp(context, email);
      Fluttertoast.showToast(msg: response.message);

      // HANYA navigasi jika request OTP berhasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = "Waktu koneksi habis, silakan coba lagi";
          break;
        case DioExceptionType.connectionError:
          errorMessage = "Tidak ada koneksi internet, periksa jaringan Anda";
          break;
        default:
          if (e.response?.statusCode == 404) {
            errorMessage = "Email tidak terdaftar di sistem kami";
          } else if (e.response?.statusCode == 500) {
            errorMessage = "Server sedang sibuk, silakan coba lagi nanti";
          } else {
            errorMessage = "Gagal mengirim OTP, silakan coba lagi";
          }
      }

      Fluttertoast.showToast(msg: errorMessage);
    } catch (_) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan tak terduga");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Text(
                        'Request OTP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 35,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email yang diinput merupakan email aktif terdaftar di aplikasi Getsayor!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFFEDF0F1), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFFEDF0F1), width: 1),
                  ),
                  contentPadding:
                      const EdgeInsets.only(left: 20, top: 18, bottom: 18),
                  labelText: 'Masukkan email',
                  labelStyle: const TextStyle(
                      fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(
                      Icons.alternate_email,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestOtp, // Cegah spam klik
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF74B11A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _isLoading ? 'Loading...' : 'Request OTP',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const LoginScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "Back to login?",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
