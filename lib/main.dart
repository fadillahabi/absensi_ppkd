import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/view/auth_screen/login_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/register_screen.dart';
import 'package:ppkd_flutter/view/edit_profile_screen.dart';
import 'package:ppkd_flutter/view/splash_screen.dart';
import 'package:ppkd_flutter/widgets/buttom_navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        '/': (context) => const SplashScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegisterScreen.id: (context) => const RegisterScreen(),
        EditProfileScreen.id: (context) => const EditProfileScreen(),
        // Jangan daftarkan lagi HomeScreen, MapScreen, dll jika pakai dari BottomNav
      },
      onGenerateRoute: (settings) {
        if (settings.name == CustomButtonNavBar.id) {
          final index = settings.arguments as int? ?? 0;
          return MaterialPageRoute(
            builder: (_) => CustomButtonNavBar(currentIndex: index),
          );
        }
        return null;
      },
      title: 'OneTapIn',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.purpleMain),
      ),
    );
  }
}
