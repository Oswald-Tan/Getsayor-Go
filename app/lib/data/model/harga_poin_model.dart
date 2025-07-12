class HargaPoinModel {
  final int hargaPoin;

  HargaPoinModel({required this.hargaPoin});

  factory HargaPoinModel.fromJson(Map<String, dynamic> json) {
    return HargaPoinModel(
      hargaPoin: json['hargaPoin'] as int,
    );
  }
}
