class Produk {
  final int id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductItem> productItems;
  bool isFavorite;

  Produk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.productItems,
    this.isFavorite = false,
  });

  // Getter untuk harga terendah (jika ada beberapa varian)
  int get hargaPoinTerendah {
    if (productItems.isEmpty) return 0;
    productItems.sort((a, b) => a.hargaPoin.compareTo(b.hargaPoin));
    return productItems.first.hargaPoin;
  }

  // Getter untuk varian pertama (jika hanya ada satu varian)
  ProductItem get varianUtama => productItems.first;

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: _parseInt(json['ID']),
      nama: json['NameProduk'] ?? '',
      deskripsi: json['Deskripsi'] ?? '',
      kategori: json['Kategori'] ?? '',
      image: json['Image'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
      productItems: (json['ProductItems'] as List)
          .map((item) => ProductItem.fromJson(item))
          .toList(),
      isFavorite: false, // Default, bisa diupdate kemudian
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ProductItem {
  final int id;
  final int productId;
  final int stok;
  final int hargaPoin;
  final int hargaRp;
  final int jumlah;
  final String satuan;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductItem({
    required this.id,
    required this.productId,
    required this.stok,
    required this.hargaPoin,
    required this.hargaRp,
    required this.jumlah,
    required this.satuan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: _parseInt(json['ID']),
      productId: _parseInt(json['ProductID']),
      stok: _parseInt(json['Stok']),
      hargaPoin: _parseInt(json['HargaPoin']),
      hargaRp: _parseInt(json['HargaRp']),
      jumlah: _parseInt(json['Jumlah']),
      satuan: json['Satuan'] ?? '',
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
