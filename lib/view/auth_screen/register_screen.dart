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
        // Pastikan trainingId yang terpilih masih valid setelah data diperbarui
        if (trainingId != null &&
            !_trainingOptions.any((t) => t.id == trainingId)) {
          trainingId = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data batch/training. Coba lagi nanti.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality:
          50, // Kurangi kualitas gambar untuk pengiriman yang lebih cepat
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        profilePhotoBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (batchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap pilih Batch terlebih dahulu"),
          backgroundColor: Colors.orange, // Warna peringatan
        ),
      );
      return;
    }

    if (trainingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap pilih Training terlebih dahulu"),
          backgroundColor: Colors.orange, // Warna peringatan
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await UserApi.registerUser(
        name: name,
        email: email,
        password: password,
        jenisKelamin: selectedGender ?? 'L',
        profilePhoto: profilePhotoBase64 ?? "", // Kirim string kosong jika null
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
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Tunggu sejenak sebelum navigasi agar animasi snackbar terlihat
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
            "Gagal registrasi: ${e.toString().replaceFirst('Exception: ', '')}", // Hapus 'Exception: '
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    return Scaffold(
      body: SafeArea(
        child: Container(
          // Latar belakang gradien yang lebih lembut
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white, // Mulai dari putih
                AppColor.purpleMain.withOpacity(0.1), // Ungu sangat muda
                AppColor.purpleMain.withOpacity(
                  0.3,
                ), // Ungu sedikit lebih terlihat
              ],
              stops: const [0.0, 0.5, 1.0], // Kontrol transisi gradien
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, // Padding horizontal yang konsisten
                  vertical: 32, // Padding vertikal lebih besar
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                    ), // Lebar maksimum untuk form
                    child: Container(
                      // Ini adalah Container/Card untuk form registrasi
                      padding: const EdgeInsets.all(
                        28,
                      ), // Padding internal lebih besar
                      decoration: BoxDecoration(
                        color:
                            Colors
                                .white, // Latar belakang putih untuk kartu form
                        borderRadius: BorderRadius.circular(
                          24,
                        ), // Sudut lebih membulat
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.purpleMain.withOpacity(
                              0.15,
                            ), // Bayangan ungu yang lembut
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16), // Jarak atas
                            // Judul "Register"
                            Text(
                              "Daftar Akun", // Pesan yang lebih ramah
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: AppColor.purpleMain, // Warna ungu utama
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtitle "Buat akun baru untuk melanjutkan"
                            Text(
                              "Bergabunglah dengan kami sekarang!", // Pesan yang lebih menarik
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Upload Foto Profil
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50, // Ukuran avatar lebih besar
                                backgroundColor: AppColor.purpleMain
                                    .withOpacity(
                                      0.1,
                                    ), // Latar belakang abu-abu terang
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
                                          size: 32, // Ukuran ikon lebih besar
                                          color:
                                              AppColor
                                                  .purpleMain, // Warna ikon ungu
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Ketuk untuk unggah foto (opsional)",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Nama Lengkap
                            CustomInputField(
                              hintText: 'Nama Lengkap',
                              icon:
                                  Icons
                                      .person_outline, // Ikon outline lebih modern
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
                            // const SizedBox(height: 16),

                            // Gender Selector
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
                              text:
                                  _isLoading
                                      ? 'Mendaftar...'
                                      : "Daftar Sekarang",
                              isLoading: _isLoading,
                              onPressed:
                                  _isLoading
                                      ? null // Nonaktifkan tombol saat loading
                                      : () {
                                        if (_formKey.currentState!.validate()) {
                                          _register();
                                        }
                                      },
                              backgroundColor:
                                  AppColor.purpleMain, // Warna ungu utama
                            ),
                            const SizedBox(height: 24),

                            // Link ke Login
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
                                      color:
                                          AppColor
                                              .purpleMain, // Warna ungu utama
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
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
                            const SizedBox(height: 16), // Jarak bawah
                          ],
                        ),
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
