// history_screen.dart

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
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  String selectedMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    initializeDateFormatting('id_ID').then((_) {
      setState(() {
        selectedMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());
      });
      fetchHistory();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchHistory();
    }
  }

  Future<void> fetchHistory() async {
    final token = await PreferencesOTI.getToken();
    if (token == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await AbsenServices.fetchAbsenHistory(token);
      setState(() {
        historyData = data;
        isLoading = false;
      });
      _fadeController.forward(from: 0.0);
      _slideController.forward(from: 0.0);
    } catch (e) {
      debugPrint('Gagal memuat history absen: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAttendanceDetailDialog(HistoryAbsenData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Detail Kehadiran",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.purpleMain,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(
                  "Tanggal",
                  DateFormat(
                    'dd MMMM yyyy',
                    'id_ID',
                  ).format(data.attendanceDate),
                ),
                const Divider(),
                if (data.status == Status.MASUK) ...[
                  _buildDetailRow(
                    "Clock In",
                    data.checkInTime ?? 'N/A',
                    icon: Icons.login,
                  ),
                  _buildDetailRow(
                    "Lokasi Masuk",
                    data.checkInAddress ?? 'N/A',
                    icon: Icons.location_on,
                  ),
                  _buildDetailRow(
                    "Clock Out",
                    data.checkOutTime ?? 'N/A',
                    icon: Icons.logout,
                  ),
                  _buildDetailRow(
                    "Lokasi Keluar",
                    data.checkOutAddress ?? 'N/A',
                    icon: Icons.location_on,
                  ),
                ] else if (data.status == Status.IZIN) ...[
                  _buildDetailRow(
                    "Status",
                    "Izin",
                    icon: Icons.info_outline,
                    textColor: Colors.orange,
                  ),
                  _buildDetailRow(
                    "Alasan Izin",
                    data.alasanIzin ?? 'Tidak ada alasan',
                    icon: Icons.sticky_note_2_outlined,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Tutup",
                style: TextStyle(color: AppColor.purpleMain),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: textColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: fetchHistory,
        color: AppColor.purpleMain,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
            ),
            SliverToBoxAdapter(child: _buildMonthSelector()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColor.purpleMain,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Riwayat Kehadiran",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.purpleMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${filteredData.length} data",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.purpleMain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (isLoading) return _buildShimmerCard();
                if (index == filteredData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Center(
                      child: Text(
                        '© 2025 Fadillah Abi Prayogo. All Rights Reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  );
                }
                if (filteredData.isEmpty) return _buildEmptyState();

                final item = filteredData[index];
                final day = DateFormat(
                  'EEEE',
                  'id_ID',
                ).format(item.attendanceDate);
                final date = DateFormat('dd').format(item.attendanceDate);

                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: () => _showAttendanceDetailDialog(item),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: index == filteredData.length - 1 ? 16 : 16,
                        ),
                        child:
                            item.status == Status.IZIN
                                ? _buildIzinCard(
                                  date: date,
                                  day: day,
                                  alasan: item.alasanIzin ?? "-",
                                )
                                : _buildAttendanceCard(
                                  date: date,
                                  day: day,
                                  checkIn: item.checkInTime ?? '-',
                                  checkOut: item.checkOutTime ?? '-',
                                ),
                      ),
                    ),
                  ),
                );
              }, childCount: isLoading ? 5 : filteredData.length + 1),
            ),
          ],
        ),
      ),
    );
  }

  // -- UI components di bawah sini sama seperti sebelumnya, tanpa perubahan signifikan
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.purpleMain, AppColor.purpleMain.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _circle(200, 0.1)),
          Positioned(bottom: -30, left: -30, child: _circle(100, 0.05)),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "History",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Pantau kehadiran Anda dengan mudah",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );

  Widget _buildMonthSelector() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = selectedMonth == month;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedMonth = month),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.purpleMain : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isSelected
                              ? AppColor.purpleMain.withOpacity(0.3)
                              : Colors.black.withOpacity(0.08),
                      blurRadius: isSelected ? 15 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    month,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDateBox(date, day),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckInfo("Clock In", checkIn, Icons.login, Colors.green),
                const SizedBox(height: 12),
                _buildCheckInfo(
                  "Clock Out",
                  checkOut,
                  Icons.logout,
                  Colors.red,
                ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E7), Color(0xFFFFF4E5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDateBox(date, day),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "IZIN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  alasan,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.purpleMain.withOpacity(0.1),
            AppColor.purpleMain.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.purpleMain.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColor.purpleMain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColor.purpleMain.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInfo(
    String label,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Tidak ada data absen",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Belum ada riwayat kehadiran untuk bulan ini",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Container(height: 16, width: 150, color: Colors.grey[200]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
