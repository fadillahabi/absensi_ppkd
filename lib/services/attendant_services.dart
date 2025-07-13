import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppkd_flutter/api/endpoint.dart';
import 'package:ppkd_flutter/models/checkout_response_model.dart';

import '../helper/shared_preference.dart';
import '../models/checkin_response_model.dart';

Future<CheckInResponse?> checkIn({
  required double latitude,
  required double longitude,
  required String address,
}) async {
  final token = await PreferencesOTI.getToken(); // Pastikan token valid

  // Format waktu dan tanggal saat ini
  final now = DateTime.now();
  final dateNow = now.toIso8601String().split('T')[0]; // yyyy-MM-dd
  final timeNow =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

  try {
    final response = await http.post(
      Uri.parse(Endpoint.checkIn),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'attendance_date': dateNow,
        'check_in': timeNow,
        'check_in_lat': latitude,
        'check_in_lng': longitude,
        'check_in_address': address,
        'status': 'masuk',
      }),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return CheckInResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal Check In: ${response.statusCode}');
    }
  } catch (e) {
    print("Check In Error: $e");
    return null;
  }
}

Future<CheckOutResponse?> checkOut({
  required double latitude,
  required double longitude,
  required String address,
}) async {
  final token = await PreferencesOTI.getToken();

  final now = DateTime.now();
  final dateNow = now.toIso8601String().split('T')[0]; // yyyy-MM-dd
  final timeNow =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}"; // HH:mm

  print(
    "Sending checkout with lat: $latitude, lng: $longitude, address: $address",
  );
  print("Token: $token");

  final response = await http.post(
    Uri.parse(Endpoint.checkOut),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode({
      "attendance_date": dateNow,
      "check_out": timeNow,
      "check_out_lat": latitude,
      "check_out_lng": longitude,
      "check_out_address": address,
    }),
  );

  print("Status Code: ${response.statusCode}");
  print("Response: ${response.body}");

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return CheckOutResponse.fromJson(json);
  } else {
    return null;
  }
}
