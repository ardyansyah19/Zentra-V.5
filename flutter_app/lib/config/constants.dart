class AppConfig {
  // Ganti dengan alamat IP komputer Anda saat menjalankan di HP fisik.
  // 10.0.2.2 = alias localhost khusus untuk Android Emulator.
  // Untuk iOS Simulator, gunakan 'http://localhost:4000'.
  static const String baseUrl = 'http://10.0.2.2:4000';
  static const String apiUrl = '$baseUrl/api';
  static const String socketUrl = baseUrl;
}
