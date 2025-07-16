// To parse this JSON StatDataAbsen, do
//
//     final statAbsenResponse = statAbsenResponseFromJson(jsonString);

import 'dart:convert';

StatAbsenResponse statAbsenResponseFromJson(String str) =>
    StatAbsenResponse.fromJson(json.decode(str));

String statAbsenResponseToJson(StatAbsenResponse data) =>
    json.encode(data.toJson());

class StatAbsenResponse {
  String message;
  StatDataAbsen data;

  StatAbsenResponse({required this.message, required this.data});

  factory StatAbsenResponse.fromJson(Map<String, dynamic> json) =>
      StatAbsenResponse(
        message: json["message"],
        data: StatDataAbsen.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class StatDataAbsen {
  int totalAbsen;
  int totalMasuk;
  int totalIzin;
  bool sudahAbsenHariIni;
  // ⭐ ADD THESE TWO NEW FIELDS ⭐
  String? todayCheckInTime; // Nullable, as it might not exist yet
  String?
  todayCheckOutTime; // Nullable, as it might not exist yet or user hasn't checked out

  StatDataAbsen({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
    // ⭐ ADD THEM TO THE CONSTRUCTOR ⭐
    this.todayCheckInTime,
    this.todayCheckOutTime,
  });

  factory StatDataAbsen.fromJson(Map<String, dynamic> json) => StatDataAbsen(
    totalAbsen: json["total_absen"],
    totalMasuk: json["total_masuk"],
    totalIzin: json["total_izin"],
    sudahAbsenHariIni: json["sudah_absen_hari_ini"],
    // ⭐ PARSE THEM FROM JSON ⭐
    // Ensure these keys ('today_check_in_time', 'today_check_out_time')
    // exactly match what your API sends. Adjust if your API uses different names.
    todayCheckInTime: json["today_check_in_time"],
    todayCheckOutTime: json["today_check_out_time"],
  );

  Map<String, dynamic> toJson() => {
    "total_absen": totalAbsen,
    "total_masuk": totalMasuk,
    "total_izin": totalIzin,
    "sudah_absen_hari_ini": sudahAbsenHariIni,
    // ⭐ ADD THEM TO TOJSON ⭐
    "today_check_in_time": todayCheckInTime,
    "today_check_out_time": todayCheckOutTime,
  };
}
