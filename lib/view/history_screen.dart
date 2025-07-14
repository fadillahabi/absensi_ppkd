import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/models/absen_history_model.dart';
import 'package:ppkd_flutter/services/absen_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  static const String id = "/history_screen";

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());

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

  List<HistoryAbsenData> historyData = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID').then((_) {
      setState(() {
        selectedMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());
      });
      fetchHistory();
    });
  }

  Future<void> fetchHistory() async {
    final token = await PreferencesOTI.getToken();
    if (token == null) return;

    try {
      final data = await AbsenServices.fetchAbsenHistory(token);
      setState(() {
        historyData = data;
      });
    } catch (e) {
      debugPrint('Gagal memuat history absen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData =
        historyData.where((item) {
          final monthName = DateFormat(
            'MMMM',
            'id_ID',
          ).format(item.attendanceDate);
          return monthName == selectedMonth;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildSummaryStats(filteredData),
          const SizedBox(height: 8),
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
            child:
                filteredData.isEmpty
                    ? const Center(child: Text("Tidak ada data absen."))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];
                        final day = DateFormat(
                          'EEEE',
                          'id_ID',
                        ).format(item.attendanceDate);
                        final date = DateFormat(
                          'dd',
                        ).format(item.attendanceDate);

                        if (item.status == Status.IZIN) {
                          return _buildIzinCard(
                            date: date,
                            day: day,
                            alasan: item.alasanIzin ?? "-",
                          );
                        }

                        return _buildAttendanceCard(
                          date: date,
                          day: day,
                          checkIn: item.checkInTime ?? '-',
                          checkOut: item.checkOutTime ?? '-',
                        );
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
        color: AppColor.purpleMain,
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
                          color:
                              isSelected ? AppColor.purpleMain : Colors.white,
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

  Widget _buildSummaryStats(List<HistoryAbsenData> data) {
    int hadir = data.where((d) => d.status == Status.MASUK).length;
    int izin = data.where((d) => d.status == Status.IZIN).length;
    int total = data.length;
    int kosong = total - hadir - izin;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard("Hadir", hadir, Colors.green),
          _buildStatCard("Izin", izin, Colors.orange),
          _buildStatCard("Kosong", kosong, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard({
    required String date,
    required String day,
    required String checkIn,
    required String checkOut,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDateBox(date, day),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckInfo("Check In", checkIn),
                const SizedBox(height: 8),
                _buildCheckInfo("Check Out", checkOut),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIzinCard({
    required String date,
    required String day,
    required String alasan,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent),
      ),
      child: Row(
        children: [
          _buildDateBox(date, day),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Izin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alasan,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String date, String day) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAFE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.purpleMain,
            ),
          ),
          Text(
            day,
            style: const TextStyle(fontSize: 12, color: AppColor.purpleMain),
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
            color: AppColor.purpleMain,
          ),
        ),
      ],
    );
  }
}
