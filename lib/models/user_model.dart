class UserModel {
  final String name;
  final String email;
  final String jenisKelamin;
  final String profilePhoto;
  final int batchId;
  final int trainingId;

  UserModel({
    required this.name,
    required this.email,
    required this.jenisKelamin,
    required this.profilePhoto,
    required this.batchId,
    required this.trainingId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      jenisKelamin: json['jenis_kelamin'],
      profilePhoto: json['profile_photo'],
      batchId: json['batch_id'],
      trainingId: json['training_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'jenis_kelamin': jenisKelamin,
    'profile_photo': profilePhoto,
    'batch_id': batchId,
    'training_id': trainingId,
  };
}
