import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    // Pastikan dotenv sudah di-load dan bisa mengakses nilai BASE_URL
    return dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
  }
}
