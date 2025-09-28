class Poin {
  final int id;
  final int poin;
  final String productId;
  final String? promoProductId;

  Poin({
    required this.id,
    required this.poin,
    required this.productId,
    this.promoProductId,
  });

  factory Poin.fromJson(Map<String, dynamic> json) {
    return Poin(
      id: json['ID'] ?? json['id'],
      poin: json['Poin'] ?? json['poin'],
      productId: json['ProductID'] ?? json['productId'],
      promoProductId:
          (json['PromoProductID']?.toString().trim().isEmpty ?? true)
              ? null
              : json['PromoProductID'],
    );
  }
}
