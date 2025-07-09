import 'package:flutter/material.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/view/auth_screen/login_screen.dart';
import 'package:ppkd_flutter/widgets/buttom_navbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    changePage();
  }

  Future<void> changePage() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = await PreferencesOTI.getToken();

    if (token != null && token.isNotEmpty) {
      // ✅ Ganti ke BottomNav dengan index 0 (Home)
      Navigator.pushNamedAndRemoveUntil(
        context,
        CustomButtonNavBar.id,
        (route) => false,
        arguments: 0,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.id,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset('assets/images/logo.png', width: size.width * 1),
        ),
      ),
    );
  }
}
