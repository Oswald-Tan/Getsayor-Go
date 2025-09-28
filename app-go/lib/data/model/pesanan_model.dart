class PesananModel {
  final String orderId;
  final String invoiceNumber;
  final int totalBayar;
  final String status;
  final int hargaPoin;
  final int hargaRp;
  final int ongkir;
  final String paymentStatus;
  final String metodePembayaran;
  final List<OrderItemModel> items;
  final String createdAt;
  final String updatedAt;

  PesananModel({
    required this.orderId,
    required this.invoiceNumber,
    required this.totalBayar,
    required this.status,
    required this.hargaPoin,
    required this.hargaRp,
    required this.ongkir,
    required this.paymentStatus,
    required this.metodePembayaran,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      orderId: json['orderId'] ?? json['OrderId'] ?? '', // Handle both cases
      invoiceNumber: json['invoiceNumber'] ?? json['InvoiceNumber'] ?? '',
      totalBayar: json['totalBayar'] ?? json['TotalBayar'] ?? 0,
      status: json['status'] ?? json['Status'] ?? '',
      hargaRp: json['hargaRp'] ?? json['HargaRp'] ?? 0,
      hargaPoin: json['hargaPoin'] ?? json['HargaPoin'] ?? 0,
      ongkir: json['ongkir'] ?? json['Ongkir'] ?? 0,
      paymentStatus: json['paymentStatus'] ?? json['PaymentStatus'] ?? '',
      metodePembayaran:
          json['metodePembayaran'] ?? json['MetodePembayaran'] ?? '',
      items: (json['orderItems'] as List? ?? json['OrderItems'] as List? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      createdAt: json['createdAt'] ?? json['CreatedAt'] ?? '',
      updatedAt: json['updatedAt'] ?? json['UpdatedAt'] ?? '',
    );
  }
}

class OrderItemModel {
  final String namaProduk;
  final int jumlah;
  final int berat;
  final int harga;
  final int totalHarga;
  final String satuan;
  final String? image;
  final String createdAt;

  OrderItemModel({
    required this.namaProduk,
    required this.jumlah,
    required this.berat,
    required this.harga,
    required this.totalHarga,
    required this.satuan,
    this.image,
    required this.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      namaProduk: json['namaProduk'] ?? json['NamaProduk'] ?? '',
      jumlah: json['jumlah'] ?? json['Jumlah'] ?? 0,
      berat: json['berat'] ?? json['Berat'] ?? 0,
      harga: json['harga'] ?? json['Harga'] ?? 0,
      totalHarga: json['totalHarga'] ?? json['TotalHarga'] ?? 0,
      satuan: json['satuan'] ?? json['Satuan'] ?? '',
      image: json['image'] ?? json['Image'] ?? '', // Sesuai dengan respons API
      createdAt: json['createdAt'] ?? json['CreatedAt'] ?? '',
    );
  }
}
