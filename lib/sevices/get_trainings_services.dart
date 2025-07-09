import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppkd_flutter/api/endpoint.dart';
import 'package:ppkd_flutter/models/trainings_model.dart';

class TrainingsServices {
  static Map<String, String> getHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<TrainingsResponse> fetchTrainings() async {
    // Get token from preferences

    final response = await http.get(
      Uri.parse(Endpoint.training),
      headers: getHeaders(),
    );

    //print(response.body);

    if (response.statusCode == 200) {
      // ✔️ Di sini kita parsing ke TrainingsResponse, bukan DataTrainings

      return TrainingsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load trainings');
    }
  }
}
