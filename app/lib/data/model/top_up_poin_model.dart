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
      id: json['id'],
      topupId: json['topupId'],
      userId: json['userId'],
      points: json['points'],
      price: json['price'],
      date: json['created_at'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
    );
  }
}
