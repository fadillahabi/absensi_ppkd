import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/models/batch_training_model.dart'
    as model; // ✅ alias

import '../models/user_model.dart';
import 'endpoint.dart';

class UserApi {
  /// REGISTER USER
  static Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required String profilePhoto,
    required int batchId,
    required int trainingId,
  }) async {
    try {
      final body = {
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhoto,
        "batch_id": batchId,
        "training_id": trainingId,
      };

      final response = await http.post(
        Uri.parse(Endpoint.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data);

        await PreferenceHandlerAbsensi.saveLogin(true);
        await PreferenceHandlerAbsensi.saveUserData(user);

        if (data['token'] != null) {
          await PreferenceHandlerAbsensi.saveToken(data['token']);
        }
        if (data['user_id'] != null) {
          await PreferenceHandlerAbsensi.saveUserId(data['user_id']);
        }

        return null; // null berarti berhasil
      } else {
        return data['message'] ?? "Registrasi gagal";
      }
    } catch (e) {
      print("Error register: $e");
      return "Terjadi kesalahan pada sistem";
    }
  }

  /// LOGIN USER
  static Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final body = {"email": email, "password": password};

      final response = await http.post(
        Uri.parse(Endpoint.login),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);

        await PreferenceHandlerAbsensi.saveLogin(true);
        await PreferenceHandlerAbsensi.saveUserData(user);

        if (data['token'] != null) {
          await PreferenceHandlerAbsensi.saveToken(data['token']);
        }
        if (data['user_id'] != null) {
          await PreferenceHandlerAbsensi.saveUserId(data['user_id']);
        }

        return true;
      } else {
        print("Login gagal: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error login: $e");
      return false;
    }
  }

  /// GET BATCHES
  static Future<List<model.Batch>> getBatches() async {
    final response = await http.get(Uri.parse(Endpoint.batch));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list =
          data is List ? data : data['data']; // ← penting

      return list.map((e) => model.Batch.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil batch');
    }
  }

  static Future<List<model.Training>> getTrainings() async {
    final response = await http.get(Uri.parse(Endpoint.training));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list =
          data is List ? data : data['data']; // ← penting

      return list.map((e) => model.Training.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil training');
    }
  }
}
