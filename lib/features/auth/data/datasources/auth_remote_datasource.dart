import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_config.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String username, String email, String password);
  Future<UserModel> updateUser(
    int id,
    String username,
    String email,
    String? password,
    String jwt,
  );
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;
  final String baseUrl = AppConfig.baseUrl;

  AuthRemoteDatasourceImpl(this.client);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  @override
  Future<UserModel> register(
      String username, String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Register gagal: ${response.body}');
    }
  }

  @override
  Future<UserModel> updateUser(
    int id,
    String username,
    String email,
    String? password,
    String jwt,
  ) async {
    final body = {
      'username': username,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
    };

    final response = await client.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update user: ${response.body}');
    }
  }
}
