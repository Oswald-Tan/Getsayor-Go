import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Kebijakan Privasi',
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
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: Color(0xFF2196F3),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Kebijakan Privasi",
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
                      color: const Color(0xFF2196F3),
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
                    _buildPrivacySection(
                      '1. Informasi yang Kami Kumpulkan',
                      'Kami mengumpulkan informasi pribadi yang Anda berikan kepada kami ketika membuat akun, melakukan pembelian, atau menggunakan fitur lain di aplikasi kami. Informasi ini termasuk, namun tidak terbatas pada, nama, alamat email, nomor telepon, alamat pengiriman, dan informasi pembayaran. Kami juga dapat mengumpulkan data teknis seperti alamat IP, jenis perangkat, dan data penggunaan aplikasi.',
                      Icons.info_outline,
                      const Color(0xFF2196F3),
                    ),
                    _buildPrivacySection(
                      '2. Penggunaan Informasi Pribadi',
                      'Kami menggunakan informasi pribadi Anda untuk memproses transaksi, memberikan layanan pelanggan, dan mengirimkan pembaruan atau penawaran terkait produk dan layanan kami. Kami juga dapat menggunakan data untuk meningkatkan pengalaman pengguna, menyesuaikan konten, dan menganalisis penggunaan aplikasi untuk tujuan pengembangan.',
                      Icons.person_outline,
                      const Color(0xFF4CAF50),
                    ),
                    _buildPrivacySection(
                      '3. Perlindungan Data',
                      'Kami berkomitmen untuk melindungi data pribadi Anda. Kami menggunakan berbagai langkah keamanan, termasuk enkripsi, untuk melindungi informasi pribadi yang Anda kirimkan kepada kami. Kami juga membatasi akses ke data pribadi hanya kepada mereka yang perlu mengetahuinya untuk menjalankan layanan kami.',
                      Icons.shield_outlined,
                      const Color(0xFF9C27B0),
                    ),
                    _buildPrivacySection(
                      '4. Pengungkapan Informasi kepada Pihak Ketiga',
                      'Kami tidak akan membagikan informasi pribadi Anda kepada pihak ketiga kecuali dalam kasus-kasus tertentu, seperti ketika diperlukan untuk memproses pembayaran, mengirimkan produk, atau memenuhi kewajiban hukum. Kami bekerja dengan mitra yang berwenang untuk memastikan bahwa data Anda tetap aman.',
                      Icons.group_outlined,
                      const Color(0xFFFF9800),
                    ),
                    _buildPrivacySection(
                      '5. Pembaruan Kebijakan',
                      'Kami berhak untuk memperbarui kebijakan privasi ini sewaktu-waktu. Pembaruan akan diumumkan melalui aplikasi atau situs web kami, dan kebijakan yang diperbarui akan berlaku segera setelah diposting.',
                      Icons.update_outlined,
                      const Color(0xFF607D8B),
                    ),
                    _buildPrivacySection(
                      '6. Hak Anda',
                      'Anda memiliki hak untuk mengakses, memperbaiki, atau menghapus informasi pribadi Anda. Jika Anda ingin mengelola pengaturan privasi atau meminta informasi tentang data yang kami simpan, silakan hubungi kami melalui kontak yang tersedia.',
                      Icons.verified_user_outlined,
                      const Color(0xFFF44336),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Data Protection Cards
            _buildDataProtectionCards(),

            // Contact Section
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.contact_support_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hubungi Kami',
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
                    'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini atau ingin menggunakan hak privasi Anda, silakan hubungi tim dukungan kami melalui email atau fitur bantuan dalam aplikasi.',
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
        color: const Color(0xFF2196F3).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Privasi Anda adalah prioritas kami. Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda.',
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

  Widget _buildPrivacySection(
      String title, String content, IconData icon, Color color,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
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

  Widget _buildDataProtectionCards() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Komitmen Keamanan Data',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2131),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildSecurityCard(
                  'Enkripsi Data',
                  'Data Anda dienkripsi dengan standar industri',
                  Icons.lock_outline,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecurityCard(
                  'Kontrol Akses',
                  'Akses terbatas hanya untuk yang berwenang',
                  Icons.admin_panel_settings_outlined,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSecurityCard(
                  'Audit Berkala',
                  'Sistem keamanan diaudit secara rutin',
                  Icons.fact_check_outlined,
                  const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecurityCard(
                  'Compliance',
                  'Mematuhi standar perlindungan data',
                  Icons.verified_outlined,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2131),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
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
