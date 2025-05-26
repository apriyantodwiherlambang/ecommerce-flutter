import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Inisialisasi instance FlutterSecureStorage
final _storage = FlutterSecureStorage();

// Menyimpan JWT ke dalam secure storage
Future<void> saveJwt(String? jwt) async {
  print('Menyimpan JWT: $jwt'); // Debugging
  if (jwt != null && jwt.isNotEmpty) {
    try {
      await _storage.write(key: 'jwt', value: jwt);
      print('JWT berhasil disimpan');
    } catch (e) {
      print('Error saat menyimpan JWT: $e');
    }
  } else {
    print('JWT kosong atau null, tidak disimpan');
  }
}

// Mengambil JWT dari secure storage
Future<String?> getJwt() async {
  try {
    final jwt = await _storage.read(key: 'jwt');
    print('JWT yang diambil: $jwt');
    return jwt;
  } catch (e) {
    print('Error saat mengambil JWT: $e');
    return null;
  }
}

// Menghapus JWT dari secure storage
Future<void> deleteJwt() async {
  try {
    await _storage.delete(key: 'jwt');
    print('JWT telah dihapus');
  } catch (e) {
    print('Error saat menghapus JWT: $e');
  }
}

// Menyimpan refresh token ke dalam secure storage
Future<void> saveRefreshToken(String? token) async {
  print('Menyimpan refresh token: $token');
  if (token != null && token.isNotEmpty) {
    try {
      await _storage.write(key: 'refreshToken', value: token);
      print('Refresh token berhasil disimpan');
    } catch (e) {
      print('Error saat menyimpan refresh token: $e');
    }
  } else {
    print('Refresh token kosong atau null, tidak disimpan');
  }
}

// Mengambil refresh token dari secure storage
Future<String?> getRefreshToken() async {
  try {
    final token = await _storage.read(key: 'refreshToken');
    print('Refresh token yang diambil: $token');
    return token;
  } catch (e) {
    print('Error saat mengambil refresh token: $e');
    return null;
  }
}

// Menghapus refresh token dari secure storage
Future<void> deleteRefreshToken() async {
  try {
    await _storage.delete(key: 'refreshToken');
    print('Refresh token telah dihapus');
  } catch (e) {
    print('Error saat menghapus refresh token: $e');
  }
}
