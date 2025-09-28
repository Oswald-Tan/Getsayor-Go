class BankAccount {
  final int? id;
  final int userId;
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  BankAccount({
    this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        id: json['ID'] ?? json['id'], // Handle both cases
        userId: json['UserID'] ?? json['userId'], // Handle both cases
        bankName: json['BankName'],
        accountNumber: json['AccountNumber'],
        accountHolder: json['AccountHolder'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolder': accountHolder,
      };
}
