import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppkd_flutter/api/endpoint.dart';
import 'package:ppkd_flutter/models/bathes_models.dart';

class BatchesServices {
  static Map<String, String> getHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<BatchesResponse> fetchBatches() async {
    final response = await http.get(
      Uri.parse(Endpoint.batch),
      headers: getHeaders(),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return BatchesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load batches');
    }
  }
}
