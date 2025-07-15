import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart'; // Pastikan path ini benar
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/services/auth_services.dart';
import 'package:ppkd_flutter/view/auth_screen/forgot_password_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/register_screen.dart';
import 'package:ppkd_flutter/widgets/buttom_navbar.dart';
// import 'package:ppkd_flutter/widgets/custom_input_field.dart'; // Mungkin tidak perlu lagi jika menggunakan TextFormField langsung
// import 'package:ppkd_flutter/widgets/custom_password_field.dart'; // Mungkin tidak perlu lagi jika menggunakan TextFormField langsung
import 'package:ppkd_flutter/widgets/main_button.dart'; // Pastikan MainButton Anda fleksibel

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = "/login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: AppColor.purpleMain),
          ), // Warna loading
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            // Latar belakang gradien yang lebih lembut dari putih ke ungu muda
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    // Ini adalah Container/Card untuk form login
                    padding: const EdgeInsets.all(28), // Padding lebih besar
                    decoration: BoxDecoration(
                      color:
                          Colors
                              .white, // Latar belakang putih untuk kartu login
                      borderRadius: BorderRadius.circular(
                        24,
                      ), // Sudut lebih membulat
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.purpleMain.withOpacity(
                            0.15,
                          ), // Bayangan ungu yang lembut
                          blurRadius: 20, // Blur yang lebih besar
                          spreadRadius: 2, // Sedikit menyebar
                          offset: const Offset(
                            0,
                            10,
                          ), // Mengangkat kartu lebih tinggi
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min, // Agar kolom tidak memakan ruang lebih
                        children: [
                          const SizedBox(height: 16), // Jarak atas
                          // Judul "Login"
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 34, // Ukuran font lebih besar
                              fontWeight: FontWeight.bold,
                              color: AppColor.purpleMain, // Warna ungu utama
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Subtitle "Let's get started"
                          Text(
                            "Selamat datang kembali!", // Pesan yang lebih personal
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ), // Warna abu-abu gelap
                          ),
                          const SizedBox(height: 32),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              labelText: 'Email', // Label teks
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColor.purpleMain,
                              ), // Ikon ungu
                              filled: true,
                              fillColor:
                                  Colors
                                      .grey
                                      .shade50, // Latar belakang field yang sangat ringan
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Sudut membulat
                                borderSide:
                                    BorderSide.none, // Tanpa border default
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColor.purpleMain.withOpacity(0.3),
                                ), // Border ungu muda
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColor.purpleMain,
                                  width: 2,
                                ), // Border ungu tebal saat fokus
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
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
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: Colors.black87,
                            ), // Warna teks input
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true, // Untuk menyembunyikan password
                            decoration: InputDecoration(
                              hintText: 'Password',
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColor.purpleMain,
                              ), // Ikon ungu
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColor.purpleMain.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColor.purpleMain,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                            style: TextStyle(
                              color: Colors.black87,
                            ), // Warna teks input
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  ForgotPasswordScreen.id,
                                );
                              },
                              child: Text(
                                "Lupa Sandi?",
                                style: TextStyle(
                                  color:
                                      AppColor.purpleMain, // Warna ungu utama
                                  fontWeight:
                                      FontWeight.w600, // Sedikit lebih tebal
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ), // Jarak sebelum tombol login
                          // Button Login with Loading
                          MainButton(
                            text: 'Masuk',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _showLoadingDialog(); // Tampilkan loading

                                try {
                                  final user = await UserApi.loginUser(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );

                                  await PreferencesOTI.saveLoginSession();

                                  if (!mounted) return;
                                  Navigator.pop(context); // Tutup loading

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Berhasil login! Selamat datang kembali',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
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

                                  await Future.delayed(
                                    const Duration(milliseconds: 800),
                                  );

                                  if (!mounted) return;
                                  Navigator.pushReplacementNamed(
                                    context,
                                    CustomButtonNavBar.id,
                                    arguments: 0,
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  Navigator.pop(
                                    context,
                                  ); // Tutup loading saat error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Login gagal: ${e.toString().replaceFirst('Exception: ', '')}', // Hapus "Exception: "
                                      ),
                                      backgroundColor:
                                          Colors
                                              .red[600], // Warna merah gelap untuk error
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      duration: const Duration(seconds: 3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            backgroundColor:
                                AppColor.purpleMain, // Warna ungu utama
                          ),

                          const SizedBox(
                            height: 24,
                          ), // Jarak setelah tombol login
                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ), // Warna divider lebih terang
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'atau',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ), // Warna teks abu-abu gelap
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Google Button
                          SizedBox(
                            // Bungkus dengan SizedBox untuk kontrol lebar
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Fitur Google Sign-In masih dalam pengembangan',
                                    ),
                                    backgroundColor: Colors.orange[600],
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },

                              icon: Image.asset(
                                'assets/images/logogugu.png', // Pastikan logo ini memiliki latar belakang transparan atau putih
                                height: 20, // Ukuran ikon lebih besar
                                width: 20,
                              ),
                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ), // Padding vertikal untuk teks
                                child: Text(
                                  'Masuk dengan Google',
                                  style: TextStyle(
                                    color:
                                        Colors
                                            .grey
                                            .shade800, // Warna teks abu-abu gelap
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppColor
                                        .purpleMain, // Warna ikon dan teks default
                                side: BorderSide(
                                  color: AppColor.purpleMain.withOpacity(0.5),
                                  width: 1.5,
                                ), // Border ungu muda
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12, // Padding vertikal lebih besar
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Sudut lebih membulat
                                ),
                                backgroundColor:
                                    Colors.white, // Latar belakang putih
                                elevation: 3, // Tambahkan elevasi
                                shadowColor: AppColor.purpleMain.withOpacity(
                                  0.1,
                                ), // Bayangan lembut
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Facebook Button
                          SizedBox(
                            // Bungkus dengan SizedBox untuk kontrol lebar
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Fitur Facebook Sign-In masih dalam pengembangan',
                                    ),
                                    backgroundColor: Colors.orange[600],
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.facebook,
                                color: Color(0xFF1877F2), // Warna asli Facebook
                                size: 20,
                              ),
                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  'Masuk dengan Facebook',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.purpleMain,
                                side: BorderSide(
                                  color: AppColor.purpleMain.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: AppColor.purpleMain.withOpacity(
                                  0.1,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Register Link
                          RichText(
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                              ), // Warna dan ukuran teks disesuaikan
                              children: [
                                TextSpan(
                                  text: 'Daftar disini',
                                  style: TextStyle(
                                    color:
                                        AppColor.purpleMain, // Warna ungu utama
                                    fontWeight: FontWeight.bold, // Lebih tebal
                                    decoration:
                                        TextDecoration
                                            .underline, // Tambahkan underline
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const RegisterScreen(),
                                            ),
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
