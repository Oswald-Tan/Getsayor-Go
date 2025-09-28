class TopUpPoin {
  final int id;
  final String topupId;
  final int userId;
  final int points;
  final int price;
  final String date;
  final String paymentMethod;
  final String status;

  TopUpPoin({
    required this.id,
    required this.topupId,
    required this.userId,
    required this.points,
    required this.price,
    required this.date,
    required this.paymentMethod,
    required this.status,
  });

  factory TopUpPoin.fromJson(Map<String, dynamic> json) {
    return TopUpPoin(
      id: json['ID'] ?? json['id'],
      topupId: json['TopupID'],
      userId: json['UserID'],
      points: json['Points'],
      price: json['Price'],
      date: json['CreatedAt'],
      paymentMethod: json['PaymentMethod'],
      status: json['Status'],
    );
  }
}
