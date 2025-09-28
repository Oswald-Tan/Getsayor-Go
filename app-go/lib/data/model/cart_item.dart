class CartItem {
  final int id;
  final int userId;
  final int productItemId;
  int quantity;
  final ProductItem productItem;

  CartItem({
    required this.id,
    required this.userId,
    required this.productItemId,
    required this.quantity,
    required this.productItem,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _parseInt(json['ID'] ?? json['id']),
      userId: _parseInt(json['UserID'] ?? json['user_id']),
      productItemId:
          _parseInt(json['ProductItemID'] ?? json['product_item_id']),
      quantity:
          _parseInt(json['Quantity'] ?? json['quantity'], defaultValue: 1),
      productItem:
          ProductItem.fromJson(json['ProductItem'] ?? json['product_item']),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class ProductItem {
  final int id;
  final int productId;
  final int stok;
  final int hargaPoin;
  final int hargaRp;
  final String satuan;
  final int jumlah;
  final String? image;
  final String nameProduk;

  ProductItem({
    required this.id,
    required this.productId,
    required this.stok,
    required this.hargaPoin,
    required this.hargaRp,
    required this.satuan,
    required this.jumlah,
    this.image,
    required this.nameProduk,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: _parseInt(json['ID'] ?? json['id']),
      productId: _parseInt(json['ProductID'] ?? json['product_id']),
      stok: json['Stok'] ?? json['stok'],
      hargaPoin: json['HargaPoin'] ?? json['hargaPoin'],
      hargaRp: json['HargaRp'] ?? json['hargaRp'],
      satuan: json['Satuan'] ?? json['satuan'],
      jumlah: _parseInt(json['Jumlah'] ?? json['jumlah']),
      image: json['Image'] ?? json['image'],
      nameProduk: json['NameProduk'] ?? json['nameProduk'],
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
