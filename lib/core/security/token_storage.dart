import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage.g.dart';

class StoredTokens {
  const StoredTokens({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;
}

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth.accessToken';
  static const _accessTokenExpiresAtKey = 'auth.accessTokenExpiresAt';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _refreshTokenExpiresAtKey = 'auth.refreshTokenExpiresAt';

  Future<StoredTokens?> read() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return StoredTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: _parseDate(
        await _storage.read(key: _accessTokenExpiresAtKey),
      ),
      refreshTokenExpiresAt: _parseDate(
        await _storage.read(key: _refreshTokenExpiresAtKey),
      ),
    );
  }

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> save(StoredTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
      _storage.write(
        key: _accessTokenExpiresAtKey,
        value: tokens.accessTokenExpiresAt?.toIso8601String(),
      ),
      _storage.write(
        key: _refreshTokenExpiresAtKey,
        value: tokens.refreshTokenExpiresAt?.toIso8601String(),
      ),
    ]);
  }

  Future<void> clear() {
    return Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _accessTokenExpiresAtKey),
      _storage.delete(key: _refreshTokenExpiresAtKey),
    ]);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}

@riverpod
FlutterSecureStorage flutterSecureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@riverpod
TokenStorage tokenStorage(Ref ref) {
  return TokenStorage(ref.watch(flutterSecureStorageProvider));
}
