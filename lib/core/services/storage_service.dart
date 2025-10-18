import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/auth_models.dart';
import '../constants/auth_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Save user data
  Future<bool> saveUser(UserModel user) async {
    try {
      final userData = json.encode(user.toJson());
      await prefs.setString(AuthConstants.userDataKey, userData);
      await prefs.setString(AuthConstants.accessTokenKey, user.accessToken);
      await prefs.setString(AuthConstants.refreshTokenKey, user.refreshToken);
      await prefs.setBool(AuthConstants.isLoggedInKey, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user data
  UserModel? getUser() {
    try {
      final userData = prefs.getString(AuthConstants.userDataKey);
      if (userData == null) return null;
      
      final Map<String, dynamic> userMap = json.decode(userData);
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  // Get access token
  String? getAccessToken() {
    return prefs.getString(AuthConstants.accessTokenKey);
  }

  // Get refresh token
  String? getRefreshToken() {
    return prefs.getString(AuthConstants.refreshTokenKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return prefs.getBool(AuthConstants.isLoggedInKey) ?? false;
  }

  // Clear all user data (logout)
  Future<bool> clearUserData() async {
    try {
      await prefs.remove(AuthConstants.userDataKey);
      await prefs.remove(AuthConstants.accessTokenKey);
      await prefs.remove(AuthConstants.refreshTokenKey);
      await prefs.setBool(AuthConstants.isLoggedInKey, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update access token
  Future<bool> updateAccessToken(String accessToken, DateTime expiresAt) async {
    try {
      await prefs.setString(AuthConstants.accessTokenKey, accessToken);
      
      // Update user data with new token
      final user = getUser();
      if (user != null) {
        final updatedUser = UserModel.fromEntity(
          user.copyWith(
            accessToken: accessToken,
            expiresAt: expiresAt,
          ),
        );
        await saveUser(updatedUser);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

