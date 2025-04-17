import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_config.dart'; // Impor AppConfig
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String username, String email, String password);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;

  AuthRemoteDatasourceImpl(this.client);

  final String baseUrl = AppConfig.baseUrl;

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
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
      body: jsonEncode(
          {'username': username, 'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Register gagal: ${response.body}');
    }
  }
}
