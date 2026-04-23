import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment.dart';

class StorageService {
  static const _key = 'payments';

  Future<List<Payment>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded.map((e) => Payment.fromJson(e)).toList();
  }

  Future<void> savePayments(List<Payment> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(payments.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }
}
