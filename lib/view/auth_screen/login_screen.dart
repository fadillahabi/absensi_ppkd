import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/services/auth_services.dart';
import 'package:ppkd_flutter/view/auth_screen/forgot_password_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/register_screen.dart';
import 'package:ppkd_flutter/widgets/buttom_navbar.dart';
import 'package:ppkd_flutter/widgets/custom_input_field.dart';
import 'package:ppkd_flutter/widgets/custom_password_field.dart';
import 'package:ppkd_flutter/widgets/main_button.dart';

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
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEDEDED), Color(0xFF0C0C1E)],
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Let's get started",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        const SizedBox(height: 32),

                        // Email Input
                        CustomInputField(
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Input
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
                            child: const Text(
                              "Lupa Sandi?",
                              style: TextStyle(color: AppColor.cyanText),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

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
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Berhasil login! Selamat datang kembali 👋',
                                            style: TextStyle(
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
                                      'Login gagal: ${e.toString()}',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          backgroundColor: AppColor.purpleMain,
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: const [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'atau',
                                style: TextStyle(color: Colors.white60),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Google Button
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/images/logogugu.png',
                            height: 16,
                            width: 16,
                          ),
                          label: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Masuk dengan Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.transparent,
                            alignment: Alignment.center,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Facebook Button
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.facebook,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Masuk dengan Facebook',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.transparent,
                            alignment: Alignment.center,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register Link
                        RichText(
                          text: TextSpan(
                            text: 'Belum punya akun? ',
                            style: const TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: 'Daftar disini',
                                style: const TextStyle(
                                  color: AppColor.cyanText,
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
          );
        },
      ),
    );
  }
}
