import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/models/bathes_model.dart';
import 'package:ppkd_flutter/models/trainings_model.dart';
import 'package:ppkd_flutter/services/auth_services.dart';
import 'package:ppkd_flutter/view/auth_screen/login_screen.dart';
import 'package:ppkd_flutter/widgets/batch_dropdown.dart';
import 'package:ppkd_flutter/widgets/custom_input_field.dart';
import 'package:ppkd_flutter/widgets/custom_password_field.dart';
import 'package:ppkd_flutter/widgets/gender_selector.dart';
import 'package:ppkd_flutter/widgets/main_button.dart';
import 'package:ppkd_flutter/widgets/training_dropdown.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String id = "/register_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedGender = 'L';
  int? batchId;
  int? trainingId;
  String? profilePhotoBase64;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<BatchesData> _batchOptions = [];
  List<DataTrainings> _trainingOptions = [];

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
        if (!_trainingOptions.any((t) => t.id == trainingId)) {
          trainingId = null;
        }
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data batch/training')),
      );
    }
  }

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

    if (!mounted) return;
    setState(() => _isLoading = true);

    if (batchId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih Batch terlebih dahulu")),
      );
      return;
    }

    if (trainingId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih Training terlebih dahulu")),
      );
      return;
    }

    try {
      await UserApi.registerUser(
        name: name,
        email: email,
        password: password,
        jenisKelamin: selectedGender ?? 'L',
        profilePhoto: profilePhotoBase64 ?? "",
        batchId: batchId!,
        trainingId: trainingId!,
      );

      if (!mounted) return;

      // Set loading false sebelum pindah halaman
      setState(() => _isLoading = false);

      // Tampilkan snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil! Silakan login."),
          backgroundColor: Colors.green,
        ),
      );

      // Tunggu sejenak sebelum navigasi agar context aman
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal registrasi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEDEDED), Color(0xFF0C0C1E)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Buat akun baru untuk melanjutkan",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Upload Foto
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 40,
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
                                        size: 28,
                                        color: Colors.grey,
                                      )
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Tap foto untuk unggah (opsional)",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),

                          // Nama
                          CustomInputField(
                            hintText: 'Nama',
                            icon: Icons.person,
                            controller: _nameController,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Nama tidak boleh kosong'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          CustomInputField(
                            hintText: 'Email',
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          CustomPasswordField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Gender
                          GenderSelector(
                            selectedGender: selectedGender,
                            onChanged:
                                (val) => setState(() => selectedGender = val),
                          ),
                          const SizedBox(height: 16),

                          // Batch Dropdown
                          BatchDropdown(
                            batchOptions: _batchOptions,
                            selectedValue: batchId,
                            onChanged: (val) => setState(() => batchId = val),
                          ),
                          const SizedBox(height: 16),

                          // Training Dropdown
                          TrainingDropdown(
                            trainingOptions: _trainingOptions,
                            selectedValue: trainingId,
                            onChanged:
                                (val) => setState(() => trainingId = val),
                          ),
                          const SizedBox(height: 24),

                          // Tombol Daftar
                          MainButton(
                            text: "Daftar",
                            isLoading: _isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _register();
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          // Link ke Login
                          RichText(
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
                                                  (_) => const LoginScreen(),
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
