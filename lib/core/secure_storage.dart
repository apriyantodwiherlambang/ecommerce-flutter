import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Inisialisasi instance FlutterSecureStorage
final _storage = FlutterSecureStorage();

// Menyimpan JWT ke dalam secure storage
Future<void> saveJwt(String jwt) async {
  print('Menyimpan JWT: $jwt'); // Debugging untuk memastikan JWT yang disimpan

  if (jwt.isNotEmpty) {
    try {
      // Menyimpan JWT dengan key 'jwt'
      await _storage.write(key: 'jwt', value: jwt);
      print('JWT berhasil disimpan');
    } catch (e) {
      // Jika terjadi error, log errornya
      print('Error saat menyimpan JWT: $e');
    }
  } else {
    print('JWT kosong, tidak disimpan');
  }
}

// Mengambil JWT dari secure storage
Future<String?> getJwt() async {
  try {
    // Membaca JWT yang disimpan dengan key 'jwt'
    String? jwt = await _storage.read(key: 'jwt');
    print(
        'JWT yang diambil: $jwt'); // Debugging untuk memastikan JWT yang diambil
    return jwt;
  } catch (e) {
    // Jika terjadi error, log errornya
    print('Error saat mengambil JWT: $e');
    return null;
  }
}

// Menghapus JWT dari secure storage
Future<void> deleteJwt() async {
  try {
    // Menghapus JWT yang disimpan dengan key 'jwt'
    await _storage.delete(key: 'jwt');
    print('JWT telah dihapus');
  } catch (e) {
    // Jika terjadi error, log errornya
    print('Error saat menghapus JWT: $e');
  }
}
