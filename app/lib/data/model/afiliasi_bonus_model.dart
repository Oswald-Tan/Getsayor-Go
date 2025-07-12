class AfiliasiBonus {
  final int id;
  final int bonusAmount;
  final String expiryDate;
  final String bonusReceivedAt;
  final String status;

  AfiliasiBonus({
    required this.id,
    required this.bonusAmount,
    required this.expiryDate,
    required this.bonusReceivedAt,
    required this.status,
  });

  // Factory method untuk mengonversi dari JSON ke objek Dart
  factory AfiliasiBonus.fromJson(Map<String, dynamic> json) {
    return AfiliasiBonus(
      id: json['id'],
      bonusAmount: json['bonusAmount'],
      expiryDate: json['expiryDate'],
      bonusReceivedAt: json['bonusReceivedAt'],
      status: json['status'],
    );
  }
}
