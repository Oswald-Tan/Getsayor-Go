import 'package:flutter/material.dart';
import 'package:getsayor/data/model/address_model.dart';
import 'package:getsayor/data/model/city_province_model.dart';
import 'package:getsayor/data/services/address_service.dart';
import 'package:getsayor/data/services/city_province_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditAddressPage extends StatefulWidget {
  final Address address;

  const EditAddressPage({super.key, required this.address});

  @override
  EditAddressPageState createState() => EditAddressPageState();
}

class EditAddressPageState extends State<EditAddressPage> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController recipientNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController addressLine1Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController postalCodeController;
  bool isDefault = false;

  // Tambahkan state untuk Province dan City
  final ProvinceService _provinceService = ProvinceService();
  List<Province> _provinces = [];
  List<City> _cities = [];
  Province? _selectedProvince;
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    recipientNameController =
        TextEditingController(text: widget.address.recipientName);
    phoneNumberController =
        TextEditingController(text: widget.address.phoneNumber);
    addressLine1Controller =
        TextEditingController(text: widget.address.addressLine1);
    cityController = TextEditingController(text: widget.address.city);
    stateController = TextEditingController(text: widget.address.state);
    postalCodeController =
        TextEditingController(text: widget.address.postalCode);
    isDefault = widget.address.isDefault;

    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _provinceService.fetchProvinces(context);
      setState(() {
        _provinces = provinces;
      });

      // Set the province and city after the provinces are loaded
      Province? selectedProvince = _provinces.firstWhere(
        (province) => province.name == widget.address.state,
        orElse: () => _provinces[0],
      );
      _onProvinceChanged(selectedProvince);
    } catch (error) {
      // Handle error
      debugPrint('Error: $error');
    }
  }

  void _onProvinceChanged(Province? selectedProvince) {
    setState(() {
      _selectedProvince = selectedProvince;
      _cities = selectedProvince?.cities ?? [];
      _selectedCity = null;
      // Update city and state controllers
      stateController.text = selectedProvince?.name ?? '';
      cityController.text = '';

      // Cari kota yang sesuai dengan widget.address.city dan pilih kota tersebut
      if (_cities.isNotEmpty) {
        City? selectedCity = _cities.firstWhere(
          (city) => city.name == widget.address.city,
          orElse: () => _cities[0], // Atur kota pertama jika tidak ditemukan
        );
        _onCityChanged(selectedCity);
      }
    });
  }

  void _onCityChanged(City? selectedCity) {
    setState(() {
      _selectedCity = selectedCity;
      cityController.text = selectedCity?.name ?? ''; // Update city controller
    });
  }

  @override
  void dispose() {
    recipientNameController.dispose();
    phoneNumberController.dispose();
    addressLine1Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  void updateAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await AddressService().editAddress(
          context: context,
          id: widget.address.id,
          recipientName: recipientNameController.text,
          phoneNumber: phoneNumberController.text,
          addressLine1: addressLine1Controller.text,
          city: cityController.text,
          state: stateController.text,
          postalCode: postalCodeController.text,
          isDefault: isDefault,
        );

        if (mounted) {
          Fluttertoast.showToast(
            msg: "Address updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0,
          );

          // Kembali ke dua halaman sebelumnya
          // Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Failed to update address: $e",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Alamat',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                        controller: recipientNameController,
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
                          labelText: 'Nama Penerima',
                          labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 14),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter recipient name'
                            : null,
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
                        controller: phoneNumberController,
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
                          labelText: 'Nomor Telepon',
                          labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 14),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter phone number' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alamat',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressLine1Controller,
                        minLines: 3, // Jumlah minimum baris
                        maxLines:
                            null, // Tidak ada batasan jumlah maksimum baris
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
                              left: 20, top: 15, bottom: 15),
                          labelText: 'Alamat',
                          labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 14),
                        ),
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
                        readOnly: true, // Membuat field tidak bisa diedit
                        controller: TextEditingController(
                            text: _selectedProvince?.name ?? ''),
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
                          hintText: 'Pilih',
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
                        readOnly: true, // Membuat field tidak bisa diedit
                        controller: TextEditingController(
                            text: _selectedCity?.name ?? ''),
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
                          hintText: 'Pilih',
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
                        controller: postalCodeController,
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
                          labelText: 'Kode Pos',
                          labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kode pos tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text(
                      "Jadikan Alamat Utama",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    value: isDefault,
                    onChanged: (value) => setState(() => isDefault = value),
                    activeColor: const Color(0xFF74B11A),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.white,
                    tileColor: Colors.white,
                    selectedTileColor: Colors.blue.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : updateAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74B11A),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
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
                            'Save Changes',
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
