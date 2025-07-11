import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  static const String id = "/history_screen";

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedMonth = 'Juli'; // default saat pertama kali dibuka
  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final List<Map<String, String>> dummyAttendance = List.generate(
    4,
    (index) => {
      'date': '13',
      'day': 'Monday',
      'checkIn': '07 : 50 : 00',
      'checkOut': '17 : 50 : 00',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Kehadiran",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: dummyAttendance.length,
              itemBuilder: (context, index) {
                return _buildAttendanceCard(dummyAttendance[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF5A32DC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              months.map((month) {
                final isSelected = selectedMonth == month;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        month,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Color(0xFF5A32DC) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xFFEAEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['date'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A32DC),
                  ),
                ),
                Text(
                  item['day'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A32DC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckInfo("Check In", item['checkIn'] ?? '-'),
                const SizedBox(height: 8),
                _buildCheckInfo("Check Out", item['checkOut'] ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInfo(String label, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A32DC),
          ),
        ),
      ],
    );
  }
}
