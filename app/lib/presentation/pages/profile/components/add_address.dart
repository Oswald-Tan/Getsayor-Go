import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/profile/components/alamat_saya.dart';
import 'package:getsayor/data/services/address_service.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/data/model/city_province_model.dart';
import 'package:getsayor/data/services/city_province_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

  @override
  AddAddressState createState() => AddAddressState();
}

class AddAddressState extends State<AddAddress> {
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controller for form fields
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  bool _isDefault = false;

  final ProvinceService _provinceService = ProvinceService();
  List<Province> _provinces = [];
  List<City> _cities = [];
  Province? _selectedProvince;
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _provinceService.fetchProvinces(context);
      setState(() {
        _provinces = provinces;
      });
    } catch (error) {
      // Handle error
      debugPrint('Error: $error');
    }
  }

  void _onProvinceChanged(Province? selectedProvince) {
    setState(() {
      _selectedProvince = selectedProvince;
      _cities = selectedProvince?.cities ?? [];
      _selectedCity = null; // Reset city selection when province changes
    });
  }

  void _onCityChanged(City? selectedCity) {
    setState(() {
      _selectedCity = selectedCity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tambah Alamat Baru',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
            fontSize: 16,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF0F1F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Recipient Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Penerima',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _recipientNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        } else if (value.length < 4) {
                          return 'Nama Penerima must be at least 3 characters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        floatingLabelBehavior:
                            FloatingLabelBehavior.never, // Matikan label bawaan
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                // Phone Number
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
                          return null;
                        } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Nomor telepon hanya boleh berisi angka';
                        } else if (value.length < 10 || value.length > 14) {
                          return 'Nomor telepon harus memiliki 10 hingga 14 digit';
                        }
                        return null; // Nomor telepon valid
                      },
                      keyboardType: TextInputType.phone,
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
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Address Line 1
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat Lengkap',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // Tidak ada pesan error jika kosong
                        } else if (value.length < 5) {
                          return 'Alamat harus memiliki setidaknya 5 karakter';
                        } else if (value.length > 100) {
                          return 'Alamat tidak boleh lebih dari 100 karakter';
                        } else if (!RegExp(r'^[a-zA-Z0-9\s.,-]+$')
                            .hasMatch(value)) {
                          return 'Alamat hanya boleh berisi huruf, angka, spasi, koma, titik, atau tanda hubung';
                        }
                        return null;
                      },
                      minLines: 3, // Jumlah minimum baris
                      maxLines: null, // Tidak ada batasan jumlah maksimum baris
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
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
                            left: 20, top: 15, bottom: 15), // Tinggi padding
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provinsi',
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
                        hintText: _selectedProvince?.name ?? 'Pilih',
                        hintStyle: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 14),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            color: Colors.grey,
                            Icons.arrow_drop_down_rounded,
                          ),
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ProvinceCityBottomSheet(
                              provinces: _provinces,
                              cities: const [],
                              onProvinceSelected: (province) {
                                setState(() {
                                  _selectedProvince = province;
                                  _cities = province?.cities ?? [];
                                  _selectedCity =
                                      null; // Reset kota saat provinsi berubah
                                });
                              },
                              onCitySelected:
                                  (city) {}, // Tidak digunakan untuk provinsi
                              isProvince: true,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Dropdown State
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kota',
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
                        hintText: _selectedCity?.name ?? 'Pilih',
                        hintStyle: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 14),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            color: Colors.grey,
                            Icons.arrow_drop_down_rounded,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (_selectedProvince == null) {
                          Fluttertoast.showToast(
                            msg: "Pilih provinsi terlebih dahulu",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                          return;
                        }
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ProvinceCityBottomSheet(
                              provinces: const [],
                              cities: _cities,
                              onProvinceSelected:
                                  (province) {}, // Tidak digunakan untuk kota
                              onCitySelected: (city) {
                                setState(() {
                                  _selectedCity = city;
                                });
                              },
                              isProvince: false,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Postal Code
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kode Pos',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _postalCodeController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kode pos tidak boleh kosong';
                        }
                        return null;
                      },
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
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),

                // Default Address Switch
                SwitchListTile(
                  title: const Text(
                    "Jadikan Alamat Utama",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: _isDefault,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isDefault = newValue;
                    });
                  },
                  activeColor: const Color(0xFF74B11A),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.white,
                  tileColor: Colors.white,
                  selectedTileColor: Colors.blue.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                ),

                // Save Button
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              await AddressService().addAddress(
                                context: context,
                                userId: userProvider.userId ?? 0,
                                recipientName: _recipientNameController.text,
                                phoneNumber: _phoneNumberController.text,
                                addressLine1: _addressController.text,
                                city: _selectedCity?.name ?? '',
                                state: _selectedProvince?.name ?? '',
                                postalCode: _postalCodeController.text,
                                isDefault: _isDefault,
                              );

                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddressPage()),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Fluttertoast.showToast(
                                  msg: "Gagal menambahkan alamat: $e",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 14.0,
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF74B11A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: isLoading
                      ? const Text(
                          'Loading...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProvinceCityBottomSheet extends StatelessWidget {
  final List<Province> provinces;
  final List<City> cities;
  final Function(Province?) onProvinceSelected;
  final Function(City?) onCitySelected;
  final bool isProvince;

  const ProvinceCityBottomSheet({
    super.key,
    required this.provinces,
    required this.cities,
    required this.onProvinceSelected,
    required this.onCitySelected,
    required this.isProvince,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
          Text(
            isProvince ? 'Pilih Provinsi' : 'Pilih Kota',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: isProvince ? provinces.length : cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    isProvince ? provinces[index].name : cities[index].name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    if (isProvince) {
                      onProvinceSelected(provinces[index]);
                    } else {
                      onCitySelected(cities[index]);
                    }
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
