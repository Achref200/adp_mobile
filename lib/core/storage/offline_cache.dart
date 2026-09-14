import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive cache for already-viewed public content only. Tokens stay in secure storage.
class OfflineCache {
  Future<void> write(String key, Object value) async =>
      (await SharedPreferences.getInstance()).setString(key, jsonEncode(value));
  Future<Map<String, dynamic>?> readMap(String key) async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<List<dynamic>?> readList(String key) async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    return raw == null ? null : jsonDecode(raw) as List<dynamic>;
  }
}
