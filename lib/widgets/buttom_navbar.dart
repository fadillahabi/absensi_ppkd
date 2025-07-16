// custom_button_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
// PASTIKAN IMPOR HISTORYSCREEN (TANPA UNDERSCORE)
import 'package:ppkd_flutter/view/history_screen.dart'; // Make sure this path is correct
import 'package:ppkd_flutter/view/home_screen.dart';
import 'package:ppkd_flutter/view/profile_screen/profile_screen.dart';

class CustomButtonNavBar extends StatefulWidget {
  final int currentIndex;
  const CustomButtonNavBar({super.key, required this.currentIndex});
  static const String id = "/bottom_navbar";

  @override
  State<CustomButtonNavBar> createState() => _CustomButtonNavBarState();
}

class _CustomButtonNavBarState extends State<CustomButtonNavBar> {
  late int _currentIndex;
  // 1. Buat GlobalKey untuk HistoryScreenState (sekarang public)
  final GlobalKey<HistoryScreenState> _historyScreenKey = GlobalKey();

  late final List<Widget> _pages; // Deklarasikan sebagai late final

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    // 2. Inisialisasi _pages di initState dan tambahkan key
    _pages = [
      const HomeScreen(),
      HistoryScreen(key: _historyScreenKey), // HistoryScreen dengan key
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // 3. Panggil fetchHistory() saat tab History dipilih
          if (index == 1) {
            // Index 1 adalah tab History
            _historyScreenKey.currentState?.fetchHistory();
          }
        },
        backgroundColor: AppColor.purpleMain,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
