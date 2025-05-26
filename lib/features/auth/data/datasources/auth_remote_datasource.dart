import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> register(String username, String email, String password);
  Future<UserModel> updateUser(
    int id,
    String? username,
    String? email,
    String? password,
    String? address,
    String? phoneNumber,
    File? profileImageFile,
    String jwt,
  );
  Future<UserModel> fetchUserProfile(String jwt);

  Future<UserModel> uploadProfileImage(File imageFile, String jwt);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl(this.dio);

  final String baseUrl = 'https://44ba-66-96-225-191.ngrok-free.app';

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post(
      '$baseUrl/users/login',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  @override
  Future<UserModel> register(
      String username, String email, String password) async {
    final response = await dio.post(
      '$baseUrl/users/register',
      data: {'username': username, 'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<UserModel> updateUser(
    int id,
    String? username,
    String? email,
    String? password,
    String? address,
    String? phoneNumber,
    File? profileImageFile,
    String jwt,
  ) async {
    final headers = {
      'Authorization': 'Bearer $jwt',
    };

    if (profileImageFile != null) {
      final fileName = profileImageFile.path.split('/').last;
      final mimeType =
          lookupMimeType(profileImageFile.path) ?? 'application/octet-stream';
      final mimeSplit = mimeType.split('/');

      final formData = FormData.fromMap({
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (address != null) 'address': address,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'image': await MultipartFile.fromFile(
          profileImageFile.path,
          filename: fileName,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      });

      final response = await dio.patch(
        '$baseUrl/users/update-profile-image',
        data: formData,
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return UserModel.fromJson(response.data['data']);
    } else {
      final Map<String, dynamic> jsonData = {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (address != null) 'address': address,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };

      final response = await dio.patch(
        '$baseUrl/users/profile',
        data: jsonData,
        options: Options(
          headers: {
            ...headers,
          },
        ),
      );

      return UserModel.fromJson(response.data['data']);
    }
  }

  @override
  Future<UserModel> fetchUserProfile(String jwt) async {
    final response = await dio.get(
      '$baseUrl/users/get-profile',
      options: Options(headers: {
        'Authorization': 'Bearer $jwt',
      }),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      if (data == null) {
        throw Exception('Data profil user kosong.');
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Format data profil user tidak valid.');
      }

      return UserModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }

  @override
  Future<UserModel> uploadProfileImage(File imageFile, String jwt) async {
    final url = '$baseUrl/users/update-profile-image';
    print('📤 Mulai upload profile image...');
    print('📦 File path: ${imageFile.path}');
    print('🔐 JWT: $jwt');
    print('🌐 URL: $url');

    try {
      final fileName = imageFile.path.split('/').last;
      final mimeType =
          lookupMimeType(imageFile.path) ?? 'application/octet-stream';
      final mimeSplit = mimeType.split('/');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      });

      final response = await dio.patch(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (_) => true,
        ),
      );

      print('✅ Status Code: ${response.statusCode}');
      print('📥 Response: ${response.data}');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Upload gagal dengan status ${response.statusCode}');
      }
    } catch (e, s) {
      print('❌ ERROR: $e');
      print('📄 STACKTRACE: $s');
      rethrow;
    }
  }
}
