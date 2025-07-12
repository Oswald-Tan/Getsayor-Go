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
      id: json['id'],
      poin: json['poin'],
      productId: json['productId'],
      promoProductId: json['promoProductId'],
    );
  }
}
