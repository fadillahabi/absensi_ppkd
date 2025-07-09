import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.purpleMain,

      body: Stack(
        children: [
          // Background putih dengan lengkungan
          Positioned(
            top: 280,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(36),
                //   topRight: Radius.circular(36),
                // ),
              ),
            ),
          ),

          // Konten utama
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          child: Image(
                            image: AssetImage("assets/images/student.png"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Selamat Pagi",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Muhammad Rio Akbar",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "123456789",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: AppColor.purpleSecond,
                    ),
                    title: const Text(
                      "Take attendance today",
                      style: TextStyle(color: AppColor.purpleMain),
                    ),
                    trailing: Icon(
                      Icons.access_time,
                      color: AppColor.purpleSecond,
                    ),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
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
                          const SizedBox(width: 6),
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
                      const SizedBox(height: 16),
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Riwayat Kehadiran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColor.purpleMain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildHistoryCard(
                  "13",
                  "Monday",
                  "07 : 50 : 00",
                  "17 : 50 : 00",
                ),
                _buildHistoryCard(
                  "12",
                  "Friday",
                  "08 : 00 : 00",
                  "17 : 00 : 00",
                ),
                _buildHistoryCard(
                  "12",
                  "Friday",
                  "08 : 00 : 00",
                  "17 : 00 : 00",
                ),
                _buildHistoryCard(
                  "12",
                  "Friday",
                  "08 : 00 : 00",
                  "17 : 00 : 00",
                ),
                _buildHistoryCard(
                  "12",
                  "Friday",
                  "08 : 00 : 00",
                  "17 : 00 : 00",
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String label, String time, {bool showButton = false}) {
    return Expanded(
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEBFA),
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
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.purpleMain,
              ),
            ),
            const SizedBox(height: 16),
            if (showButton)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.purpleMain,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Check Out",
                  style: TextStyle(color: Colors.white),
                ),
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFA),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(day, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("Check In", style: TextStyle(fontSize: 12)),
                    Text(
                      checkIn,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text("Check Out", style: TextStyle(fontSize: 12)),
                    Text(
                      checkOut,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
