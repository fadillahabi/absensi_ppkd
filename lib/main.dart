import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/view/auth_screen/login_screen.dart';
import 'package:ppkd_flutter/view/auth_screen/register_screen.dart';
import 'package:ppkd_flutter/view/edit_profile_screen.dart';
import 'package:ppkd_flutter/view/history_screen.dart';
import 'package:ppkd_flutter/view/home_screen.dart';
import 'package:ppkd_flutter/view/map_screen.dart';
import 'package:ppkd_flutter/view/profile_screen.dart';
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
        '/': (context) => SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        MapScreen.id: (context) => MapScreen(),
        HistoryScreen.id: (context) => HistoryScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        EditProfileScreen.id: (context) => EditProfileScreen(),
        CustomButtonNavBar.id:
            (context) => const CustomButtonNavBar(currentIndex: 0),
      },
      title: 'OneTapIn',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.purpleMain),
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
