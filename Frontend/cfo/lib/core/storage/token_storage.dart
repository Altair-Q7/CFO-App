import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'dart:convert';

class TokenStorage {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    // Note: In a real app, use async properly. This sync method is a convenience.
    // For production, use a stream or FutureBuilder pattern.
    return _cachedToken;
  }

  String? _cachedToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.roleKey);
    _cachedToken = null;
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user));
    if (user.containsKey('role')) {
      await prefs.setString(AppConstants.roleKey, user['role']);
    }
  }

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.roleKey, role);
  }

  String? getRole() {
    return _cachedRole;
  }

  String? _cachedRole;

  Future<void> loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(AppConstants.tokenKey);
    _cachedRole = prefs.getString(AppConstants.roleKey);
  }
}
