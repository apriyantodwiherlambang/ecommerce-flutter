import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/entities/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl;
  final _storage = FlutterSecureStorage();

  ApiService(this.baseUrl);

  // Menyimpan JWT setelah login atau registrasi
  Future<void> saveJwt(String jwt) async {
    print(
        'Menyimpan JWT: $jwt'); // Debugging untuk memastikan JWT yang disimpan
    if (jwt.isNotEmpty) {
      try {
        await _storage.write(key: 'jwt', value: jwt);
        print('JWT berhasil disimpan');
      } catch (e) {
        print('Error saat menyimpan JWT: $e'); // Log jika ada error
      }
    } else {
      print('JWT kosong, tidak disimpan');
    }
  }

  // Mengambil JWT yang tersimpan
  Future<String?> getJwt() async {
    try {
      String? jwt = await _storage.read(key: 'jwt');
      print(
          'JWT yang diambil: $jwt'); // Debugging untuk memastikan JWT yang diambil
      return jwt;
    } catch (e) {
      print('Error saat mengambil JWT: $e'); // Log jika ada error
      return null;
    }
  }

  // Menghapus JWT
  Future<void> deleteJwt() async {
    try {
      await _storage.delete(key: 'jwt');
      print('JWT telah dihapus'); // Debugging untuk memastikan JWT dihapus
    } catch (e) {
      print('Error saat menghapus JWT: $e'); // Log jika ada error
    }
  }

  // Login
  Future<UserEntity> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final jwt = data['jwt'];
      final user = UserEntity.fromJson(data['user']);
      print(
          'JWT diterima setelah login: $jwt'); // Debugging untuk memastikan JWT diterima
      await saveJwt(jwt);
      return user;
    } else {
      throw Exception('Login failed');
    }
  }

  // Registrasi
  Future<UserEntity> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final jwt = data['jwt'];
      final user = UserEntity.fromJson(data['user']);
      print(
          'JWT diterima setelah registrasi: $jwt'); // Debugging untuk memastikan JWT diterima
      await saveJwt(jwt);
      return user;
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<UserEntity> updateUser(
    int id,
    String username,
    String email,
    String? password,
  ) async {
    final jwt = await getJwt(); // Ambil JWT yang tersimpan

    if (jwt == null || jwt.isEmpty) {
      print('JWT Tidak ditemukan, Anda Perlu Login Kembali');
      throw Exception('JWT Tidak ditemukan, Anda Perlu Login Kembali');
    }

    final url = Uri.parse(
        '$baseUrl/auth/user/update/$id'); // Ganti endpoint sesuai id user
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    };

    final Map<String, dynamic> body = {
      'username': username,
      'email': email,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    print('Mengirim permintaan update user ke: $url');
    print('Header: $headers');
    print('Body: $body');

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(body),
    );

    print('Status code update user: ${response.statusCode}');
    print('Response body update user: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserEntity.fromJson(data['user']);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }
}
