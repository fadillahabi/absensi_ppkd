import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ⬅️ Tambahkan ini
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/view/attendance_screen/chechkout_screen.dart';
import 'package:ppkd_flutter/view/attendance_screen/checkin_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/change_password_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/forgot_password_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/login_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/register_screen.dart';
import 'package:ppkd_flutter/view/profile_screen/edit_profile_screen.dart';
import 'package:ppkd_flutter/view/splash_screen.dart';
import 'package:ppkd_flutter/widgets/buttom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
    'id_ID',
    null,
  ); // ⬅️ Tambahkan inisialisasi locale di sini

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
        CheckinScreen.id: (context) => const CheckinScreen(),
        CheckOutScreen.id: (context) => const CheckOutScreen(),
        ChangePasswordScreen.id:
            (context) => ChangePasswordScreen(email: 'user@email.com'),
        ForgotPasswordScreen.id: (context) => ForgotPasswordScreen(),
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
