import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getsayor/data/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/presentation/pages/loading_page.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _profileImage;
  late String _currentFullname;
  late String _phoneNumber;
  late String _email;
  late TextEditingController _fullnameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late bool _isFullnameChanged;
  late bool _isProfileImageChanged;
  late bool _isPhoneNumberChanged;
  late bool _isEmailChanged;
  bool _isLoading = true;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _profileImage = '';
    _currentFullname = '';
    _phoneNumber = '';
    _email = '';
    _fullnameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _isFullnameChanged = false;
    _isProfileImageChanged = false;
    _isPhoneNumberChanged = false;
    _isEmailChanged = false;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      setState(() => _isLoading = true); // Mulai loading

      // Simulasikan delay untuk demo (opsional)
      // await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _currentFullname = userProvider.fullname ?? '';
        _fullnameController.text = _currentFullname;
        _phoneNumber = userProvider.phoneNumber ?? '';
        _phoneNumberController.text = _phoneNumber;
        _email = userProvider.email ?? '';
        _emailController.text = _email;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat data profil");
    } finally {
      setState(() => _isLoading = false); // Selesai loading
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile.path;
        _isProfileImageChanged = true;
      });
    }
  }

  void showImagePickerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Pilih Foto',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text(
                  'Ambil foto dari gallery',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text(
                  'Ambil foto dari kamera',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId ?? 0; // Default to 0 if null

    final response = await _userService.updateUser(
      context,
      userId,
      _fullnameController.text.trim(),
      _phoneNumberController.text.trim(),
      _emailController.text.trim(),
    );

    if (response['status']) {
      Fluttertoast.showToast(msg: response['message']);
      userProvider.updateFullname(_fullnameController.text.trim());
      userProvider.updatePhoneNumber(_phoneNumberController.text.trim());
      userProvider.updateEmail(_emailController.text.trim());

      // Update local state with the new values after a successful update
      setState(() {
        _isFullnameChanged = false;
        _isPhoneNumberChanged = false;
        _isEmailChanged = false;
        _isProfileImageChanged = false;
      });
    } else {
      Fluttertoast.showToast(msg: response['message']);
    }
  }

  bool get _hasChanges {
    return _isProfileImageChanged ||
        _isFullnameChanged ||
        _isPhoneNumberChanged ||
        _isEmailChanged;
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        // showImagePickerModal(context);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: _profileImage.isNotEmpty
                ? FileImage(File(_profileImage))
                : const AssetImage('assets/images/profile_user.png')
                    as ImageProvider<Object>,
          ),
          const SizedBox(height: 8),
          // const Text(
          //   'Ganti Foto Profil',
          //   style: TextStyle(
          //     fontFamily: 'Poppins',
          //     color: Color(0xFF1F2131),
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ],
      ),
    );
  }

  final _emailValidator = RegExp(
    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-zA-Z]{2,})$',
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: LoadingPage()));
    }

    final isFullnameValid = _fullnameController.text.isNotEmpty &&
        _fullnameController.text.length >= 4;
    final isEmailValid = _emailController.text.isNotEmpty &&
        _emailValidator.hasMatch(_emailController.text);
    final isPhoneValid = _phoneNumberController.text.isNotEmpty &&
        _phoneNumberController.text.length >= 10 &&
        _phoneNumberController.text.length <= 13;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fullname',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fullnameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap harus diisi';
                      } else if (value.length < 4) {
                        return 'Nama minimal 4 karakter';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      // hintText: 'Enter your fullname',
                      // hintStyle: TextStyle(fontFamily: 'Poppins',color: Colors.grey, fontSize: 14),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.only(
                          left: 20.0, top: 15, bottom: 15),
                      labelText: 'Fullname',
                      labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 14),
                    ),
                    onChanged: (value) => setState(
                        () => _isFullnameChanged = value != _currentFullname),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email harus diisi';
                      } else if (!_emailValidator.hasMatch(value)) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      // hintText: 'Enter your email',
                      // hintStyle: TextStyle(fontFamily: 'Poppins',color: Colors.grey, fontSize: 14),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.only(
                          left: 20.0, top: 15, bottom: 15),
                      labelText: 'Email',
                      labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 14),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.alternate_email,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _isEmailChanged = value != _email),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No Handphone',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneNumberController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor HP harus diisi';
                      } else if (value.length < 10) {
                        return 'Minimal 10 digit';
                      } else if (value.length > 13) {
                        return 'Maksimal 13 digit';
                      }
                      return null;
                    },
                    keyboardType:
                        TextInputType.phone, // Set keyboard type to phone
                    decoration: InputDecoration(
                      // hintText: 'Enter your phone number',
                      // hintStyle: TextStyle(fontFamily: 'Poppins',color: Colors.grey, fontSize: 14),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.only(
                          left: 20.0, top: 15, bottom: 15),
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 14),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.phone,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(
                        () => _isPhoneNumberChanged = value != _phoneNumber),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _hasChanges &&
                        isFullnameValid &&
                        isEmailValid &&
                        isPhoneValid
                    ? _updateUserProfile
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF74B11A),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
