class TotalBonus {
  final int totalBonus;
  final String message;

  TotalBonus({required this.totalBonus, required this.message});

  factory TotalBonus.fromJson(Map<String, dynamic> json) {
    return TotalBonus(
      totalBonus: json['totalBonus'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
