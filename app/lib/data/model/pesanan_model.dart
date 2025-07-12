class PesananModel {
  final String orderId;
  final int totalBayar;
  final String status;
  final int? hargaRp;
  final int? hargaPoin;
  final String paymentStatus;
  final String metodePembayaran;
  final List<OrderItemModel> items;
  final String createdAt;

  PesananModel({
    required this.orderId,
    required this.totalBayar,
    required this.status,
    this.hargaRp,
    this.hargaPoin,
    required this.paymentStatus,
    required this.metodePembayaran,
    required this.items,
    required this.createdAt,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      orderId: json['orderId'],
      totalBayar: json['totalBayar'],
      status: json['status'],
      hargaRp: json['hargaRp'],
      hargaPoin: json['hargaPoin'],
      paymentStatus: json['paymentStatus'],
      metodePembayaran: json['metodePembayaran'],
      items: (json['orderItems'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      createdAt: json['created_at'],
    );
  }
}

class OrderItemModel {
  final String namaProduk;
  final int jumlah;
  final int berat;
  final int harga;
  final String satuan;
  final String? image;
  final String? createdAt;

  OrderItemModel({
    required this.namaProduk,
    required this.jumlah,
    required this.berat,
    required this.harga,
    required this.satuan,
    this.image,
    this.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      namaProduk: json['namaProduk'],
      jumlah: json['jumlah'],
      berat: json['berat'],
      harga: json['harga'],
      satuan: json['satuan'],
      image: json['produk']?['image'], // Akses gambar dari relasi product
      createdAt: json['created_at'],
    );
  }
}
