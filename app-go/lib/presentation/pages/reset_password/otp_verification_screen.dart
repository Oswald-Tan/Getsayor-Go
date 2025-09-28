import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';
import 'package:getsayor/presentation/pages/reset_password/reset_password_page.dart';
import 'package:getsayor/data/services/otp_request_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  bool _isLoading = false;
  String? _expiryTime; // Untuk menyimpan waktu kadaluarsa OTP
  late Timer _timer;
  int _timeLeftInSeconds = 0; // Waktu sisa dalam detik

  // Fungsi untuk memverifikasi OTP
  void _verifyOtp() async {
    String otpCode =
        _otpControllers.map((controller) => controller.text).join();

    if (otpCode.length < 6) {
      Fluttertoast.showToast(msg: "Masukkan 6 digit kode OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response =
          await OTPRequestService().verifyOtp(context, widget.email, otpCode);
      print("OTP verification response: ${response.message}");
      Fluttertoast.showToast(msg: response.message);

      if (mounted) {
        print("Navigating to ResetPasswordPage");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPasswordPage(email: widget.email)),
        );
      }
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
          if (e.response?.statusCode == 400) {
            errorMessage = "Kode OTP tidak valid";
          } else if (e.response?.statusCode == 410) {
            errorMessage = "Kode OTP telah kedaluwarsa";
          } else if (e.response?.statusCode == 404) {
            errorMessage = "Permintaan OTP tidak ditemukan";
          } else if (e.response?.statusCode == 500) {
            errorMessage = "Server sedang sibuk, silakan coba lagi nanti";
          } else {
            errorMessage = "Gagal memverifikasi OTP, silakan coba lagi";
          }
      }

      Fluttertoast.showToast(msg: errorMessage);
    } catch (_) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan tak terduga");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk mendapatkan waktu kadaluarsa OTP
  void _getOtpExpiryTime() async {
    try {
      setState(() => _isLoading = true);

      final expiryTime =
          await OTPRequestService().getResetOtpExpiry(context, widget.email);

      // Parse the expiry time directly since it's non-nullable
      final expiryDateTime = DateTime.parse(expiryTime);

      setState(() {
        _expiryTime = expiryTime;
        _timeLeftInSeconds =
            expiryDateTime.difference(DateTime.now()).inSeconds;
      });

      // Set timer untuk menghitung sisa waktu
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeftInSeconds > 0) {
          setState(() => _timeLeftInSeconds--);
        } else {
          _timer.cancel();
        }
      });
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
            errorMessage = "Permintaan OTP tidak ditemukan";
          } else if (e.response?.statusCode == 500) {
            errorMessage = "Server sedang sibuk, silakan coba lagi nanti";
          } else {
            errorMessage = "Gagal mendapatkan waktu kadaluarsa OTP";
          }
      }

      Fluttertoast.showToast(msg: errorMessage);
    } on FormatException {
      // Handle invalid date format from server
      Fluttertoast.showToast(msg: "Format waktu tidak valid");
    } catch (_) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan tak terduga");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getOtpExpiryTime();
  }

  @override
  void dispose() {
    // Jangan lupa untuk dispose controller dan timer
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_timeLeftInSeconds / 60).floor();
    final seconds = _timeLeftInSeconds % 60;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Kode OTP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    color: Color(0xFF1F2131),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Masukkan kode OTP yang telah dikirim ke ${widget.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[500]),
                ),
                const SizedBox(height: 20),
                if (_expiryTime != null)
                  Text(
                    "Waktu tersisa: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey[600]),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 53,
                      height: 53,
                      child: TextField(
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFEDF0F1), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFEDF0F1), width: 1),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF74B11A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const Text(
                            'Loading...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const Text(
                            'Verifikasi OTP',
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
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
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
      ),
    );
  }
}
