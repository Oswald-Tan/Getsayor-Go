import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2131),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Syarat & Ketentuan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF74B11A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: Color(0xFF74B11A),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Syarat dan Ketentuan",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2131),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Getsayor",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF74B11A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF74B11A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Terakhir diperbarui: 5 Januari 2025",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroText(),
                    const SizedBox(height: 24),
                    _buildTermsSection(
                      '1. Penerimaan Syarat dan Ketentuan',
                      'Dengan mengakses atau menggunakan aplikasi e-commerce kami, Anda setuju untuk mematuhi semua syarat dan ketentuan yang tercantum dalam perjanjian ini. Jika Anda tidak setuju dengan syarat dan ketentuan ini, harap jangan menggunakan aplikasi kami.',
                      Icons.check_circle_outline,
                    ),
                    _buildTermsSection(
                      '2. Penggunaan Layanan',
                      'Aplikasi ini memungkinkan Anda untuk membeli produk, menggunakan poin, dan menikmati layanan lainnya. Anda bertanggung jawab untuk menjaga kerahasiaan akun dan kata sandi Anda. Anda setuju untuk tidak menggunakan aplikasi kami untuk tujuan ilegal atau tidak sah.',
                      Icons.shopping_bag_outlined,
                    ),
                    _buildTermsSection(
                      '3. Pendaftaran Akun',
                      'Untuk menggunakan fitur tertentu di aplikasi, Anda harus membuat akun. Anda bertanggung jawab untuk memberikan informasi yang akurat dan menjaga keamanan akun Anda. Anda juga setuju untuk memberi tahu kami jika ada aktivitas yang tidak sah di akun Anda.',
                      Icons.person_outline,
                    ),
                    _buildTermsSection(
                      '4. Pembayaran dan Transaksi',
                      'Kami menyediakan layanan pembayaran dan transaksi melalui poin. Semua transaksi dilakukan dengan cara yang aman, namun Anda bertanggung jawab untuk memeriksa riwayat transaksi Anda dan memastikan bahwa informasi pembayaran yang diberikan adalah benar. Semua transaksi dianggap final dan tidak dapat dibatalkan setelah diproses.',
                      Icons.payment_outlined,
                    ),
                    _buildTermsSection(
                      '5. Pembaruan dan Perubahan Kebijakan',
                      'Kami berhak untuk memperbarui atau mengubah syarat dan ketentuan ini kapan saja tanpa pemberitahuan sebelumnya. Anda akan diberitahu tentang perubahan tersebut melalui aplikasi atau email, dan Anda setuju untuk mematuhi versi terbaru dari syarat dan ketentuan ini.',
                      Icons.update_outlined,
                    ),
                    _buildTermsSection(
                      '6. Penghentian Akun',
                      'Kami berhak untuk menangguhkan atau menghentikan akun Anda jika Anda melanggar syarat dan ketentuan ini. Anda dapat menutup akun Anda kapan saja dengan menghubungi tim dukungan kami.',
                      Icons.block_outlined,
                    ),
                    _buildTermsSection(
                      '7. Pembatasan Tanggung Jawab',
                      'Kami tidak bertanggung jawab atas kerugian atau kerusakan yang timbul dari penggunaan aplikasi kami, termasuk kesalahan dalam transaksi pembayaran atau penggunaan poin. Kami berusaha memberikan layanan terbaik, namun kami tidak dapat menjamin bahwa aplikasi akan bebas dari kesalahan atau gangguan.',
                      Icons.shield_outlined,
                    ),
                    _buildTermsSection(
                      '8. Penggunaan Poin',
                      'Sebagai bagian dari layanan kami, Anda dapat menggunakan poin untuk melakukan pembelian dan transaksi lainnya. Anda bertanggung jawab untuk menjaga keamanan saldo poin Anda. Kami tidak bertanggung jawab atas kerugian yang disebabkan oleh penggunaan yang tidak sah atau kesalahan transaksi.',
                      Icons.stars_outlined,
                    ),
                    _buildTermsSection(
                      '9. Hukum yang Berlaku',
                      'Syarat dan ketentuan ini diatur oleh hukum yang berlaku di negara kami. Segala perselisihan yang timbul akan diselesaikan melalui pengadilan yang berwenang.',
                      Icons.balance_outlined,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Footer Section
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF74B11A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF74B11A).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF74B11A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Butuh bantuan?',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2131),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Jika Anda memiliki pertanyaan tentang syarat dan ketentuan ini, silakan hubungi tim dukungan kami melalui email atau fitur bantuan dalam aplikasi.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mohon baca dengan seksama syarat dan ketentuan berikut sebelum menggunakan aplikasi Getsayor.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF1F2131),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(String title, String content, IconData icon,
      {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF74B11A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF74B11A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2131),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 16),
            Divider(
              color: Colors.grey[200],
              thickness: 1,
            ),
          ],
        ],
      ),
    );
  }

  // static String _getFormattedDate() {
  //   final now = DateTime.now();
  //   final months = [
  //     'Januari',
  //     'Februari',
  //     'Maret',
  //     'April',
  //     'Mei',
  //     'Juni',
  //     'Juli',
  //     'Agustus',
  //     'September',
  //     'Oktober',
  //     'November',
  //     'Desember'
  //   ];
  //   return '${now.day} ${months[now.month - 1]} ${now.year}';
  // }
}
