import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/profile/components/edit_address.dart';
import 'package:getsayor/data/services/address_service.dart';
import 'package:getsayor/data/model/address_model.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/presentation/pages/profile/components/add_address.dart';
import 'package:shimmer/shimmer.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  AddressPageState createState() => AddressPageState();
}

class AddressPageState extends State<AddressPage> {
  late Future<List<Address>> futureAddresses;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    futureAddresses = fetchUserAddresses();
  }

  // Fetch user addresses
  Future<List<Address>> fetchUserAddresses() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId != null) {
        return await AddressService().getUserAddresses(context, userId);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Refresh addresses list
  Future<void> _refreshAddresses() async {
    setState(() {
      _isRefreshing = true; // Tampilkan shimmer saat refresh dimulai
    });

    try {
      final newAddresses = await fetchUserAddresses();
      setState(() {
        futureAddresses = Future.value(newAddresses);
      });
    } finally {
      setState(() {
        _isRefreshing = false; // Sembunyikan shimmer saat selesai
      });
    }
  }

  // Modern error widget
  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Oops! Terjadi Kesalahan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF74B11A), Color(0xFF8EC61D)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF74B11A).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _refreshAddresses,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern empty state widget
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF74B11A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 72,
              color: Color(0xFF74B11A),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Belum Ada Alamat",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF1F2131),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Tambahkan alamat pengiriman untuk\nmemudahkan proses belanja Anda",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[600],
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildAddButton(),
        ],
      ),
    );
  }

  // Modern add button
  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF74B11A), Color(0xFF8EC61D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B11A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddress()),
          ).then((_) => _refreshAddresses());
        },
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          "Tambah Alamat Baru",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Modern address card
  Widget _buildAddressCard(Address address, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and phone
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF74B11A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF74B11A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.recipientName.length > 20
                                ? '${address.recipientName.substring(0, 20)}...'
                                : address.recipientName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF1F2131),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            address.phoneNumber,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Address details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0XFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${address.addressLine1}, ${address.city}, ${address.state} ${address.postalCode}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFF1F2131),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Default badge
                if (address.isDefault)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF74B11A), Color(0xFF8EC61D)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Alamat Utama',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // More options button
          Positioned(
            top: 12,
            right: 12,
            child: _buildOptionsMenu(address),
          ),
        ],
      ),
    );
  }

  // Modern options menu
  Widget _buildOptionsMenu(Address address) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'edit') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditAddressPage(address: address),
              ),
            );
            _refreshAddresses();
          } else if (value == 'delete') {
            _showDeleteDialog(address);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Edit Alamat',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hapus Alamat',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        icon: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.more_vert_rounded,
            color: Colors.grey[600],
            size: 18,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        color: Colors.white,
      ),
    );
  }

  // Modern delete dialog
  void _showDeleteDialog(Address address) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.red.shade400,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hapus Alamat',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2131),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menghapus alamat ini? Tindakan ini tidak dapat dibatalkan.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _deleteAddress(address),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Delete address function
  void _deleteAddress(Address address) async {
    Navigator.pop(context); // Close dialog

    try {
      bool success = await AddressService().deleteAddress(context, address.id);

      if (success) {
        Fluttertoast.showToast(
          msg: "Alamat berhasil dihapus",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        _refreshAddresses();
      }
    } catch (e) {
      String errorMessage = "Gagal menghapus alamat";

      if (e.toString().contains("timeout")) {
        errorMessage = "Koneksi terlalu lama, silakan coba lagi";
      } else if (e.toString().contains("koneksi internet")) {
        errorMessage = "Tidak ada koneksi internet, periksa jaringan Anda";
      } else if (e.toString().contains("Alamat default")) {
        errorMessage =
            "Alamat utama tidak dapat dihapus. Ubah alamat utama terlebih dahulu";
      } else if (e.toString().contains("Sesi Anda")) {
        errorMessage = "Sesi Anda telah berakhir, silakan login kembali";
      } else if (e.toString().contains("tidak ditemukan")) {
        errorMessage = "Alamat tidak ditemukan di sistem";
      } else if (e.toString().contains("Server sedang")) {
        errorMessage = "Server sedang bermasalah, silakan coba nanti";
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Modern shimmer loading
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 16,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 14,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 100,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1F2131),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alamat Pengiriman',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1F2131),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Address>>(
        future: futureAddresses,
        builder: (context, snapshot) {
          // Handle error state
          if (snapshot.hasError) {
            String errorMessage = 'Terjadi kesalahan saat memuat data';
            if (snapshot.error.toString().contains('Timeout')) {
              errorMessage =
                  'Koneksi timeout. Pastikan koneksi internet Anda stabil dan coba lagi.';
            } else if (snapshot.error.toString().contains('network')) {
              errorMessage =
                  'Tidak ada koneksi internet. Periksa jaringan Anda.';
            } else if (snapshot.error
                .toString()
                .contains('Invalid response format')) {
              errorMessage = 'Format respons tidak valid. Silakan coba lagi.';
            }
            return _buildErrorWidget(errorMessage);
          }

          // Loading state (only when there's no data yet)
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return _buildShimmerLoading();
          }

          // Empty state
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // Data loaded successfully
          final addresses = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshAddresses,
                  color: const Color(0xFF74B11A),
                  backgroundColor: Colors.white,
                  child: Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          return _buildAddressCard(addresses[index], index);
                        },
                      ),

                      // Tampilkan shimmer selama refresh
                      if (_isRefreshing)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.7),
                            child: _buildShimmerLoading(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: _buildAddButton(),
              ),
            ],
          );
        },
      ),
    );
  }
}
