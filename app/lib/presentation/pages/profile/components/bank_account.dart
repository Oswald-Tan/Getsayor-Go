import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/data/services/bank_account_service.dart';
import 'package:getsayor/presentation/pages/loading_page.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _BankAccountPageState extends State<BankAccountPage> {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final BankAccountService _service = BankAccountService();
  bool _isLoading = true;
  bool _isChanged = false;

  String _originalBankName = "";
  String _originalAccountNumber = "";
  String _originalAccountHolder = "";

  // Daftar nama bank
  final List<String> _bankList = [
    'BSG',
    'BCA',
    'Mandiri',
    'BRI',
    'BNI',
    'CIMB Niaga',
    'Danamon',
    'Permata',
    'Panin',
    'Mega',
    'Syariah Indonesia',
  ];

  @override
  void initState() {
    super.initState();
    _loadBankData();
    bankNameController.addListener(_checkChanges);
    accountNumberController.addListener(_checkChanges);
    accountHolderController.addListener(() {
      final text = accountHolderController.text;
      if (text != text.toUpperCase()) {
        accountHolderController.value = accountHolderController.value.copyWith(
          text: text.toUpperCase(),
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
      _checkChanges();
    });
  }

  Future<void> _loadBankData() async {
    setState(() => _isLoading = true);

    try {
      final account = await _service.getBankAccount(context);
      setState(() {
        if (account != null) {
          _originalBankName = account.bankName;
          _originalAccountNumber = account.accountNumber;
          _originalAccountHolder = account.accountHolder.toUpperCase();

          bankNameController.text = account.bankName;
          accountNumberController.text = account.accountNumber;
          accountHolderController.text = _originalAccountHolder;
        } else {
          // Handle null account
          _originalBankName = "";
          _originalAccountNumber = "";
          _originalAccountHolder = "";

          bankNameController.clear();
          accountNumberController.clear();
          accountHolderController.clear();
        }
      });
    } catch (e) {
      // Handle error
      print("Error loading bank data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkChanges() {
    setState(() {
      _isChanged = bankNameController.text != _originalBankName ||
          accountNumberController.text != _originalAccountNumber ||
          accountHolderController.text != _originalAccountHolder; // NEW CHECK
    });
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    final result = await _service.saveBankAccount(
      context,
      userId.toString(),
      bankNameController.text,
      accountNumberController.text,
      accountHolderController.text,
    );

    if (result != null) {
      setState(() {
        _originalBankName = bankNameController.text;
        _originalAccountNumber = accountNumberController.text;
        _originalAccountHolder = accountHolderController.text;
        _isChanged = false;
      });

      Fluttertoast.showToast(
        msg: "Data rekening berhasil disimpan.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  void _showBankSelectionModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Nama Bank Anda',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _bankList.length,
                  itemBuilder: (context, index) {
                    final bankName = _bankList[index];
                    return ListTile(
                      title: Text(
                        bankName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          bankNameController.text = bankName;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: LoadingPage()));
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Informasi Rekening',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2131),
              fontSize: 16,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFFEDF6FF),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Pastikan nama bank dan nomor rekening yang Anda masukkan sudah sesuai. Nomor rekening ini akan digunakan untuk pengiriman bonus yang Anda dapatkan.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Lengkap Pemilik Rekening',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: accountHolderController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        // Blok karakter selain huruf dan spasi
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]')),
                        // Otomatis konversi ke uppercase
                        UpperCaseTextFormatter(),
                      ],
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
                          borderSide: const BorderSide(
                              color: Color(0xFFEDF0F1), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFFEDF0F1), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 20, top: 15, bottom: 15),
                        hintText: 'Masukkan nama lengkap sesuai rekening',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nama Bank',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
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
                          borderSide: const BorderSide(
                              color: Color(0xFFEDF0F1), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFFEDF0F1), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 20, top: 15, bottom: 15, right: 18),
                        labelStyle: const TextStyle(
                            fontFamily: 'Poppins', color: Colors.grey),
                        hintText: bankNameController.text.isEmpty
                            ? 'Pilih Nama Bank'
                            : bankNameController.text,
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: bankNameController.text.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            color: Colors.grey,
                            Icons.arrow_drop_down_rounded,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showBankSelectionModal();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor Rekening',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: accountNumberController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Nomor rekening tidak boleh kosong';
                    //   } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    //     return 'Nomor rekening hanya boleh berisi angka';
                    //   } else if (value.length < 6) {
                    //     return 'Nomor rekening minimal 6 digit';
                    //   }
                    //   return null;
                    // },
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
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: Color(0xFFEDF0F1), width: 1.5),
                      ),
                      contentPadding:
                          const EdgeInsets.only(left: 20, top: 15, bottom: 15),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_originalBankName.isNotEmpty ||
                  _originalAccountNumber.isNotEmpty ||
                  _originalAccountHolder.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog(
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
                                    'Hapus Rekening',
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
                                    'Apakah Anda yakin ingin menghapus data rekening?',
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
                                      Navigator.of(context).pop();
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
                                    onPressed: () =>
                                        Navigator.pop(context, true),
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
                                      'Hapus',
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

                      if (confirmed == true) {
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        final userId = userProvider.userId;

                        final success = await _service.deleteBankAccount(
                            context, userId.toString());
                        if (success) {
                          setState(() {
                            _originalBankName = "";
                            _originalAccountNumber = "";
                            _originalAccountHolder = ""; // NEW RESET
                            bankNameController.clear();
                            accountNumberController.clear();
                            accountHolderController.clear(); // NEW CLEAR
                            _isChanged = false;
                          });

                          Fluttertoast.showToast(
                            msg: "Data rekening berhasil dihapus.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Hapus Rekening',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChanged && _formKey.currentState!.validate()
                      ? _saveData
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Simpan Rekening',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
