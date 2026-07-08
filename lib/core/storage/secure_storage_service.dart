import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserId = 'user_id';

  // Save auth data
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String name,
    required String phone,
    required String id,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserRole, value: role);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserPhone, value: phone);
    await _storage.write(key: _keyUserId, value: id);
  }

  // Update only tokens
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  // Get values
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  Future<String?> getUserPhone() async {
    return await _storage.read(key: _keyUserPhone);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // Check login status
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Clear data (logout)
  Future<void> clearAuth() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserPhone);
    await _storage.delete(key: _keyUserId);
  }
}
