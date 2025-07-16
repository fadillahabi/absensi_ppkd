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
        if (trainingId != null &&
            !_trainingOptions.any((t) => t.id == trainingId)) {
          trainingId = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data batch/training.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        profilePhotoBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (batchId == null || trainingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            batchId == null
                ? "Harap pilih Batch terlebih dahulu"
                : "Harap pilih Training terlebih dahulu",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Registrasi berhasil! Silakan login.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal registrasi: ${e.toString().replaceFirst('Exception: ', '')}",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppColor.purpleMain.withOpacity(0.1),
                AppColor.purpleMain.withOpacity(0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width > 600 ? 480 : double.infinity,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.purpleMain.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Daftar Akun",
                          style: TextStyle(
                            fontSize: isSmall ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: AppColor.purpleMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Bergabunglah dengan kami sekarang!",
                          style: TextStyle(
                            fontSize: isSmall ? 13 : 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 28),

                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: isSmall ? 40 : 50,
                            backgroundColor: AppColor.purpleMain.withOpacity(
                              0.1,
                            ),
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
                                    ? Icon(
                                      Icons.camera_alt,
                                      size: isSmall ? 24 : 32,
                                      color: AppColor.purpleMain,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Ketuk untuk unggah foto (opsional)",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isSmall ? 11 : 13,
                          ),
                        ),
                        const SizedBox(height: 24),

                        CustomInputField(
                          hintText: 'Nama Lengkap',
                          icon: Icons.person_outline,
                          controller: _nameController,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        CustomInputField(
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Email tidak boleh kosong';
                            if (!value.contains('@') || !value.contains('.'))
                              return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomPasswordField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Password tidak boleh kosong';
                            if (value.length < 6)
                              return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        GenderSelector(
                          selectedGender: selectedGender,
                          onChanged:
                              (val) => setState(() => selectedGender = val),
                        ),
                        const SizedBox(height: 16),

                        BatchDropdown(
                          batchOptions: _batchOptions,
                          selectedValue: batchId,
                          onChanged: (val) => setState(() => batchId = val),
                        ),
                        const SizedBox(height: 16),

                        TrainingDropdown(
                          trainingOptions: _trainingOptions,
                          selectedValue: trainingId,
                          onChanged: (val) => setState(() => trainingId = val),
                        ),
                        const SizedBox(height: 24),

                        MainButton(
                          text: _isLoading ? 'Mendaftar...' : "Daftar Sekarang",
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : () => _register(),
                        ),
                        const SizedBox(height: 24),

                        RichText(
                          text: TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: 'Masuk Sekarang',
                                style: TextStyle(
                                  color: AppColor.purpleMain,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            '© 2025 Fadillah Abi Prayogo. All Rights Reserved.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
