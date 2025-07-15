import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/services/forgot_password_service.dart';
import 'package:ppkd_flutter/view/auth_screen/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String id = "/change_password_screen";
  final String email;
  final bool popOnSuccess;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    this.popOnSuccess = false,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isResending = false;

  late Timer _timer;
  int _secondsRemaining = 600;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waktu habis, silakan kirim ulang OTP'),
            ),
          );
        }
      }
    });
  }

  String get _timerText {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan 6 digit kode OTP")),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak cocok")));
      return;
    }

    if (newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 8 karakter")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ForgotPasswordServices.resetPassword(
        email: widget.email,
        otp: otpController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.green),
      );

      if (widget.popOnSuccess) {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal reset password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> resendOtp() async {
    if (isResending) return;

    setState(() => isResending = true);
    try {
      final result = await ForgotPasswordServices.requestOtp(widget.email);
      _timer.cancel();
      _secondsRemaining = 600;
      _startTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal kirim ulang OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/otp_sms.png",
                  height: 120,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.sms_failed, size: 80),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Verification",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Kode dikirim ke: ${widget.email}"),
                const SizedBox(height: 8),
                Text(
                  "Waktu tersisa: $_timerText",
                  style: TextStyle(color: AppColor.purpleMain),
                ),
                const SizedBox(height: 32),
                _buildOtpField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : verifyOtp,
                  icon: const Icon(Icons.verified_user, color: Colors.white),
                  label:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            "VERIFIKASI",
                            style: TextStyle(color: Colors.white),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.purpleMain,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed:
                      (_secondsRemaining <= 0 && !isResending)
                          ? resendOtp
                          : null,
                  child:
                      isResending
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : Text.rich(
                            TextSpan(
                              text: "Belum menerima OTP? ",
                              style: const TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: "Kirim ulang",
                                  style: TextStyle(
                                    color:
                                        (_secondsRemaining <= 0)
                                            ? AppColor.purpleMain
                                            : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField() {
    return TextField(
      controller: otpController,
      maxLength: 6,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        letterSpacing: 10,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: "Masukkan OTP",
        counterText: "",
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.purpleMain),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: newPasswordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password baru',
        prefixIcon: Icon(Icons.lock_outline, color: AppColor.purpleMain),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColor.purpleMain,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: confirmPasswordController,
      obscureText: !isConfirmPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Konfirmasi password',
        prefixIcon: Icon(Icons.lock_outline, color: AppColor.purpleMain),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColor.purpleMain,
          ),
          onPressed: () {
            setState(() {
              isConfirmPasswordVisible = !isConfirmPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
