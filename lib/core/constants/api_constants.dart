// lib/core/constants/api_constants.dart
class ApiConstants {
  // Ganti ini dengan URL ngrok HTTPS Anda (pastikan pakai 'https://')
  static const String baseUrl = 'https://44ba-66-96-225-191.ngrok-free.app';
  // Untuk WebSocket, jika ngrok HTTPS, biasanya tetap pakai 'wss://'
  // TAPI karena NestJS Anda di localhost:3000, ngrok akan mengkonversi
  // WSS ke WS secara internal, jadi pakai 'wss://' jika ngrok Anda HTTPS
  static const String baseUrlWs = 'wss://44ba-66-96-225-191.ngrok-free.app';
}
