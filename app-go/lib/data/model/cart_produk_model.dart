class CartProduct {
  final String id; // ID dokumen
  final String nama;
  final int harga;
  final String imagePath;
  int berat; // Tidak final, agar bisa diubah
  final int hargaRp;

  CartProduct({
    required this.id,
    required this.nama,
    required this.harga,
    required this.imagePath,
    required this.berat, // Masih ada di konstruktor
    required this.hargaRp,
  });

  // Membuat CartProduct dari Map (biasanya data Firestore)
  factory CartProduct.fromMap(Map<String, dynamic> map, String documentId) {
    return CartProduct(
      id: documentId,
      nama: map['nama'] ?? '',
      harga: map['harga'] ?? 0,
      imagePath: map['imagePath'] ?? '',
      berat: map['berat'] ?? 0, // Pastikan mendapatkan nilai berat
      hargaRp: map['hargaRp'] ?? '',
    );
  }

  // Mengonversi CartProduct menjadi Map untuk menyimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'harga': harga,
      'imagePath': imagePath,
      'berat': berat,
      'hargaRp': hargaRp,
    };
  }

  // Implementasi perbandingan objek berdasarkan `id`
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
