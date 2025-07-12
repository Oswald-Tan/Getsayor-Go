class Produk {
  final int id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final int hargaPoin;
  final int hargaRp;
  final int jumlah;
  final String satuan;
  final String? image;
  bool isFavorite;

  Produk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.hargaPoin,
    required this.hargaRp,
    required this.jumlah,
    required this.satuan,
    this.image,
    this.isFavorite = false,
  });

  // Factory method untuk konversi dari JSON ke objek Produk
  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      nama: json['nameProduk'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      hargaPoin: json['hargaPoin'],
      hargaRp: json['hargaRp'],
      jumlah: json['jumlah'],
      satuan: json['satuan'],
      image: json['image'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
