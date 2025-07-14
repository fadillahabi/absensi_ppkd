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
  static final String checkOut = '$baseUrlApi/absen/check-out';
  static final String allHistoryAbsen = '$baseUrlApi/absen/history';
  static final String statAbsen = '$baseUrlApi/absen/stats';
  static final String permission = '$baseUrlApi/izin';
  static final String resetPassword = '$baseUrlApi/reset-password';
  static final String forgotPassword = '$baseUrlApi/forgot-password';
  static String deleteAbsen(int id) => '$baseUrlApi/absen/$id';
  static String todayAbsen(String attendanceDate) =>
      '$baseUrlApi/absen/today?attendance_date=$attendanceDate';
}
