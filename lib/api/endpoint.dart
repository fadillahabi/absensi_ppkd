class Endpoint {
  static const String baseUrl = "https://appabsensi.mobileprojp.com";
  static const String baseUrlApi = "$baseUrl/api";
  static const String register = "$baseUrlApi/register";
  static const String login = "$baseUrlApi/login";
  static const String training = "$baseUrlApi/trainings";
  static const String batch = "$baseUrlApi/batches";
  static const String profile = "$baseUrlApi/profile";
  static const String updateProfile = "$baseUrlApi/profile";
  static const String checkIn = "$baseUrlApi/absen/check-in";
  static final String checkOut = '$baseUrl/absen/check-out';
  static final String allHistoryAbsen = '$baseUrl/absen/history';
  static final String statAbsen = '$baseUrl/absen/stats';
  static final String permission = '$baseUrl/izin';
  static String todayAbsen(String attendanceDate) =>
      '$baseUrl/absen/today?attendance_date=$attendanceDate';
}
