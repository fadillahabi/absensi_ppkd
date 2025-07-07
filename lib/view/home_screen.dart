import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home_screen";

  @override
  State<HomeScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.purpleMain,
      bottomNavigationBar: _buildBottomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: (32),
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset("assets/images/student.png"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Pagi",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Muhammad Rio Akbar",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text("123456789", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: AppColor.purpleSecond,
                ),
                title: Text("Take attendance today"),
                trailing: Icon(Icons.access_time, color: AppColor.purpleSecond),
                onTap: () {},
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: AppColor.purpleMain,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Jl. Panglima Djuminang No.5, Medan Petisah, Sumatera Utara",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.purpleMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeBox("Check In", "07 : 50 : 00"),
                      _buildTimeBox(
                        "Check Out",
                        "17 : 50 : 00",
                        showButton: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Riwayat Kehadiran",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.purpleMain,
                ),
              ),
            ),
            _buildHistoryCard("13", "Monday", "07 : 50 : 00", "17 : 50 : 00"),
            _buildHistoryCard("13", "Monday", "07 : 50 : 00", "17 : 50 : 00"),

            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

Widget _buildTimeBox(String label, String time, {bool showButton = false}) {
  return Expanded(
    child: Container(
      height: 140,
      margin: EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFEDEBFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColor.purpleMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.purpleMain,
            ),
          ),
          SizedBox(height: 16),
          if (showButton)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.purpleMain,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("Check Out", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    ),
  );
}

Widget _buildHistoryCard(
  String date,
  String day,
  String checkIn,
  String checkOut,
) {
  return Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFEDEBFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(day, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Check In", style: TextStyle(fontSize: 12)),
                    Text(
                      checkIn,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Check Out", style: TextStyle(fontSize: 12)),
                    Text(
                      checkOut,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBottomNavBar() {
  return SafeArea(
    child: Container(
      decoration: BoxDecoration(
        color: AppColor.purpleMain, // Warna dominan ungu
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColor.purpleMain,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
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
      ),
    ),
  );
}
