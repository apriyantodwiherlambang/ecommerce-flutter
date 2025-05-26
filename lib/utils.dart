String fixImageUrl(String url) {
  return url.replaceAll(
      'localhost', '192.168.1.6'); // khusus untuk emulator Android
}
