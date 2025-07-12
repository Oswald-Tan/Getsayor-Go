import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PendingTransaction {
  final String purchaseId;
  final int points;
  final String price;
  final DateTime date;
  final String invoiceNumber;

  PendingTransaction({
    required this.purchaseId,
    required this.points,
    required this.price,
    required this.date,
    required this.invoiceNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'purchaseId': purchaseId,
      'points': points,
      'price': price,
      'date': date.toIso8601String(),
      'invoiceNumber': invoiceNumber,
    };
  }

  factory PendingTransaction.fromMap(Map<String, dynamic> map) {
    return PendingTransaction(
      purchaseId: map['purchaseId'],
      points: map['points'],
      price: map['price'],
      date: DateTime.parse(map['date']),
      invoiceNumber: map['invoiceNumber'],
    );
  }
}

class PendingTransactionStorage {
  static const String _key = 'pending_transactions';

  static Future<List<PendingTransaction>> getPendingTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((e) => PendingTransaction.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> savePendingTransactions(
      List<PendingTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((e) => e.toMap()).toList();
    prefs.setString(_key, json.encode(jsonList));
  }

  static Future<void> addPendingTransaction(
      PendingTransaction transaction) async {
    final List<PendingTransaction> current = await getPendingTransactions();
    current.add(transaction);
    await savePendingTransactions(current);
  }

  static Future<void> removePendingTransaction(String purchaseId) async {
    final List<PendingTransaction> current = await getPendingTransactions();
    current.removeWhere((t) => t.purchaseId == purchaseId);
    await savePendingTransactions(current);
  }
}
