import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ppkd_flutter/api/user_api.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/models/batch_training_model.dart' as model;
import 'package:ppkd_flutter/view/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String id = "/register_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedGender = 'L';
  int? batchId;
  int? trainingId;
  String? profilePhotoBase64;
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<model.Batch> _batchOptions = [];
  List<model.Training> _trainingOptions = [];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        profilePhotoBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        batchId == null ||
        trainingId == null ||
        profilePhotoBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await UserApi.registerUser(
      name: name,
      email: email,
      password: password,
      jenisKelamin: selectedGender ?? 'L',
      profilePhoto: profilePhotoBase64!,
      batchId: batchId!,
      trainingId: trainingId!,
    );

    setState(() => _isLoading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil! Silakan login."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBatchAndTraining();
  }

  Future<void> fetchBatchAndTraining() async {
    try {
      final batches = await UserApi.getBatches();
      final trainings = await UserApi.getTrainings();

      setState(() {
        _batchOptions = batches;
        _trainingOptions = trainings;
      });
    } catch (e) {
      print("Gagal ambil data batch/training: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data batch/training')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDEDED), Color(0xFF0C0C1E)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: const [
                      Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Create an account",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  child: Column(
                    children: [
                      // Upload Foto Profil
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage:
                                    profilePhotoBase64 != null
                                        ? MemoryImage(
                                          base64Decode(
                                            profilePhotoBase64!.split(',').last,
                                          ),
                                        )
                                        : null,
                                child:
                                    profilePhotoBase64 == null
                                        ? const Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.grey,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Tap foto untuk unggah",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildInputField(
                        hintText: 'Nama',
                        icon: Icons.person,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        hintText: 'Email',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 16),
                      _buildGenderSelector(),
                      const SizedBox(height: 16),
                      _buildBatchDropdown(),
                      const SizedBox(height: 16),
                      _buildTrainingDropdown(),
                      const SizedBox(height: 24),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.purpleMain,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Sudah punya akun? ',
                            style: const TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: 'Masuk Sekarang',
                                style: const TextStyle(
                                  color: AppColor.cyanText,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const LoginScreen(),
                                          ),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jenis Kelamin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _genderOptionTile(value: 'L', label: 'Laki-laki')),
            const SizedBox(width: 12),
            Expanded(child: _genderOptionTile(value: 'P', label: 'Perempuan')),
          ],
        ),
      ],
    );
  }

  Widget _genderOptionTile({required String value, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              selectedGender == value
                  ? AppColor.purpleMain
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedGender,
        title: Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
        onChanged: (value) => setState(() => selectedGender = value!),
      ),
    );
  }

  Widget _buildBatchDropdown() {
    return DropdownButtonFormField<int>(
      value: batchId,
      items:
          _batchOptions
              .map(
                (model.Batch batch) => DropdownMenuItem<int>(
                  value: batch.id,
                  child: Text(batch.name),
                ),
              )
              .toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Pilih Batch',
        prefixIcon: const Icon(Icons.list_alt),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) => setState(() => batchId = value),
    );
  }

  Widget _buildTrainingDropdown() {
    return DropdownButtonFormField<int>(
      value: trainingId,
      items:
          _trainingOptions
              .map(
                (model.Training training) => DropdownMenuItem<int>(
                  value: training.id,
                  child: Text(training.name),
                ),
              )
              .toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Pilih Training',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) => setState(() => trainingId = value),
    );
  }
}
