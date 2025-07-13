// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

import 'package:ppkd_flutter/models/bathes_model.dart';
import 'package:ppkd_flutter/models/trainings_model.dart';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String message;
  Data data;

  LoginResponse({required this.message, required this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  String token;
  UserLogin user;

  Data({required this.token, required this.user});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(token: json["token"], user: UserLogin.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"token": token, "user": user.toJson()};
}

class UserLogin {
  final int? id;
  final String? name;
  final String? email;
  final String? jenisKelamin;
  final dynamic emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profilePhotoUrl;

  final BatchesData? batch; // ✅ Tambahan
  final DataTrainings? training; // ✅ Tambahan

  UserLogin({
    this.id,
    this.name,
    this.email,
    this.jenisKelamin,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.profilePhotoUrl,
    this.batch, // ✅ Tambahan
    this.training, // ✅ Tambahan
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    jenisKelamin: json["jenis_kelamin"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt:
        json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    updatedAt:
        json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
    profilePhotoUrl:
        json["profile_photo"] != null
            ? "https://appabsensi.mobileprojp.com/public/${json["profile_photo"]}"
            : null,
    batch:
        json["batch"] != null
            ? BatchesData.fromJson(json["batch"])
            : null, // ✅ Tambahan
    training:
        json["training"] != null
            ? DataTrainings.fromJson(json["training"])
            : null, // ✅ Tambahan
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "jenis_kelamin": jenisKelamin,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "profile_photo_url": profilePhotoUrl,
    "batch": batch?.toJson(), // ✅ Tambahan
    "training": training?.toJson(), // ✅ Tambahan
  };
}
