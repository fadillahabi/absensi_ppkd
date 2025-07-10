import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppkd_flutter/api/endpoint.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/models/bathes_model.dart';
import 'package:ppkd_flutter/models/login_model.dart';
import 'package:ppkd_flutter/models/register_model.dart';
import 'package:ppkd_flutter/models/trainings_model.dart';

class UserApi {
  /// Common headers for HTTP requests
  static Map<String, String> getHeaders(String token) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Register user
  static Future<User> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required String profilePhoto,
    required int batchId,
    required int trainingId,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.register),
      headers: getHeaders(""),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'jenis_kelamin': jenisKelamin,
        'profile_photo': profilePhoto,
        'batch_id': batchId,
        'training_id': trainingId,
      }),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final registerResponse = RegisterResponse.fromJson(
        json.decode(response.body),
      );

      if (registerResponse.data?.user != null) {
        return registerResponse.data!.user!;
      } else {
        throw Exception('Register berhasil, tetapi data user tidak ditemukan.');
      }
    } else {
      throw Exception('Failed to register user.');
    }
  }

  /// Login user
  static Future<UserLogin> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.login),
      headers: getHeaders(""),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(json.decode(response.body));
      await PreferencesOTI.saveToken(loginResponse.data.token);
      return loginResponse.data.user;
    } else {
      throw Exception('Failed to login user.');
    }
  }

  /// Get Batch List
  static Future<List<BatchesData>> getBatches() async {
    final response = await http.get(Uri.parse(Endpoint.batch));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['data'];
      return jsonList.map((e) => BatchesData.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch batches');
    }
  }

  /// Get Training List
  static Future<List<DataTrainings>> getTrainings() async {
    final response = await http.get(Uri.parse(Endpoint.training));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['data'];
      return jsonList.map((e) => DataTrainings.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch trainings');
    }
  }

  static Future<UserLogin> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(Endpoint.profile),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    print("GET PROFILE RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['data'] == null) {
        throw Exception('Data profil tidak ditemukan.');
      }
      return UserLogin.fromJson(jsonData['data']);
    } else {
      throw Exception('Gagal memuat profil. Status: ${response.statusCode}');
    }
  }

  static Future<bool> updateProfile({
    required String token,
    required String name,
    required String email,
    required String jenisKelamin,
  }) async {
    final response = await http.put(
      Uri.parse(Endpoint.updateProfile), // pastikan Endpoint ini ada
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'jenis_kelamin': jenisKelamin,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal update profil. ${response.body}');
    }
  }
}
