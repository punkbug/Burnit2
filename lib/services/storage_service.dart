import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/emotion_receipt.dart';

class StorageService {
  static const String _receiptKey = 'emotion_receipts_v1';

  Future<List<EmotionReceipt>> loadReceipts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_receiptKey) ?? <String>[];

    final List<EmotionReceipt> receipts = raw
        .map((String item) => EmotionReceipt.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();

    receipts.sort((EmotionReceipt a, EmotionReceipt b) => b.createdAt.compareTo(a.createdAt));
    return receipts;
  }

  Future<void> saveReceipt(EmotionReceipt receipt) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_receiptKey) ?? <String>[];

    current.add(jsonEncode(receipt.toJson()));
    await prefs.setStringList(_receiptKey, current);
  }

  Future<void> deleteReceiptById(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_receiptKey) ?? <String>[];

    final List<String> updated = current.where((String item) {
      final Map<String, dynamic> decoded = jsonDecode(item) as Map<String, dynamic>;
      return decoded['id'] != id;
    }).toList();

    await prefs.setStringList(_receiptKey, updated);
  }

  Future<void> clearAllReceipts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_receiptKey);
  }
}
