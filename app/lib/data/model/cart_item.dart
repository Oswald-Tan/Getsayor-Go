class CartItem {
  final int id;
  final int userId;
  final int productId;
  int quantity;
  final Product product;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      quantity: json['quantity'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final int id;
  final String nameProduk;
  final int hargaPoin;
  final int hargaRp;
  final int jumlah;
  final String satuan;
  final String? image;

  Product({
    required this.id,
    required this.nameProduk,
    required this.hargaPoin,
    required this.hargaRp,
    required this.jumlah,
    required this.satuan,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nameProduk: json['nameProduk'],
      hargaPoin: json['hargaPoin'],
      hargaRp: json['hargaRp'],
      jumlah: json['jumlah'],
      satuan: json['satuan'],
      image: json['image'] ?? '',
    );
  }
}
