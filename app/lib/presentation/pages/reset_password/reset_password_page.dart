import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/presentation/pages/login_register/login_screen.dart';
import 'package:getsayor/data/services/otp_request_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool obscureTextNew = true; // Untuk password baru
  bool obscureTextConfirm = true; // Untuk konfirmasi password

  // Menyimpan status validasi kriteria password
  bool isLengthValid = false;
  bool isNumberValid = false;
  bool isUppercaseValid = false;
  bool isLowercaseValid = false;
  bool isSpecialCharacterValid = false;

  // Fungsi untuk mereset password
  void _resetPassword() async {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validasi input
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(
          msg: "Silakan masukkan password baru dan konfirmasi password");
      return;
    }

    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(msg: "Password tidak cocok");
      return;
    }

    if (!isValidPassword(newPassword)) {
      Fluttertoast.showToast(
          msg: "Password tidak memenuhi persyaratan keamanan");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await OTPRequestService().resetPassword(
        context,
        widget.email,
        newPassword,
        confirmPassword,
      );

      Fluttertoast.showToast(msg: response.message);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
            errorMessage = "Permintaan tidak valid";
          } else if (e.response?.statusCode == 401) {
            errorMessage =
                "Sesi telah berakhir, silakan mulai ulang proses reset password";
          } else if (e.response?.statusCode == 410) {
            errorMessage = "Permintaan reset password telah kadaluarsa";
          } else if (e.response?.statusCode == 500) {
            errorMessage = "Server sedang sibuk, silakan coba lagi nanti";
          } else {
            errorMessage = "Gagal mereset password, silakan coba lagi";
          }
      }

      Fluttertoast.showToast(msg: errorMessage);
    } catch (_) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan tak terduga");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool isValidPassword(String password) {
    // Check if the password has at least 8 characters, contains a number,
    // contains a lowercase letter, and contains an uppercase letter
    RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  // Fungsi untuk memvalidasi kriteria password
  void _checkPasswordCriteria(String password) {
    setState(() {
      // Validasi setiap kriteria password
      isLengthValid = password.length >= 8;
      isNumberValid = RegExp(r'\d').hasMatch(password);
      isUppercaseValid = RegExp(r'[A-Z]').hasMatch(password);
      isLowercaseValid = RegExp(r'[a-z]').hasMatch(password);
      isSpecialCharacterValid =
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                color: Color(0xFF1F2131),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter a new password for ${widget.email}",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 16, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              obscureText: obscureTextNew,
              onChanged: _checkPasswordCriteria,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      obscureTextNew = !obscureTextNew;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(
                      obscureTextNew ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ),
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
                labelText: 'New Password',
                labelStyle: const TextStyle(
                    fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: obscureTextConfirm,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      obscureTextConfirm = !obscureTextConfirm;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Icon(
                      obscureTextConfirm
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ),
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
                    const EdgeInsets.only(left: 20.0, top: 18, bottom: 18),
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(
                    fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            // Display password criteria
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password must meet the following criteria:",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600]),
                ),
                const SizedBox(height: 5),
                // Menampilkan kriteria dengan warna hijau atau merah
                Row(
                  children: [
                    Icon(
                      size: 14,
                      isLengthValid ? Icons.check_circle : Icons.cancel,
                      color: isLengthValid ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'At least 8 characters',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isLengthValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Icon(
                      size: 14,
                      isNumberValid ? Icons.check_circle : Icons.cancel,
                      color: isNumberValid ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Contains at least one number',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: isNumberValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Icon(
                      size: 14,
                      (isUppercaseValid && isLowercaseValid)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: (isUppercaseValid && isLowercaseValid)
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Contains both uppercase and lowercase letters',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: (isUppercaseValid && isLowercaseValid)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Icon(
                      size: 14,
                      isSpecialCharacterValid
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                          isSpecialCharacterValid ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'At least one special character',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color:
                            isSpecialCharacterValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
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
                        'Reset Password',
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
    );
  }
}
