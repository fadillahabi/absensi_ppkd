// import dan deklarasi tetap
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/models/login_model.dart';
import 'package:ppkd_flutter/models/stat_absen_model.dart';
import 'package:ppkd_flutter/services/absen_services.dart';
import 'package:ppkd_flutter/services/auth_services.dart';
import 'package:ppkd_flutter/view/attendance_screen/chechkout_screen.dart';
import 'package:ppkd_flutter/view/attendance_screen/checkin_screen.dart';
import 'package:ppkd_flutter/view/permission_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedTraining = "";
  UserLogin? user;
  DateTime _now = DateTime.now();
  Timer? _timer;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  String currentAddress = "Memuat lokasi...";
  bool isLoadingStats = false;

  // Removed attendanceHistory and izinList
  StatDataAbsen? absenStats; // New: to hold attendance statistics

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    initializeDateFormatting('id_ID');
    _startClock();
    getCurrentLocation();
    fetchAbsenStatistics(); // New: Fetch attendance statistics
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Removed fetchIzinList and fetchAttendanceHistory

  Future<void> _handleRefresh() async {
    await fetchUserProfile();
    await getCurrentLocation();
    await fetchAbsenStatistics(); // Refresh attendance statistics

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil diperbarui"),
          backgroundColor: AppColor.purpleMain,
        ),
      );
    }
  }

  Future<void> fetchUserProfile() async {
    final token = await PreferencesOTI.getToken();
    if (token == null) return;

    try {
      final result = await UserApi.getProfile(token);
      setState(() {
        user = result;
        selectedTraining = result.training?.title ?? "Memuat...";
      });
    } catch (e) {
      print("Gagal mengambil data user: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          currentAddress =
              "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
        });
      }
    } catch (e) {
      print("Gagal mengambil lokasi: $e");
      setState(() {
        currentAddress = "Gagal mengambil lokasi";
      });
    }
  }

  // New: fetchAbsenStatistics
  Future<void> fetchAbsenStatistics() async {
    final token = await PreferencesOTI.getToken();
    if (token == null) return;

    setState(() {
      isLoadingStats = true;
    });

    try {
      final response = await AbsenServices.fetchStatAbsen(token);
      setState(() {
        absenStats = response.data;
      });
    } catch (e) {
      print("Gagal mengambil statistik absen: $e");
    } finally {
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  Future<void> ajukanIzin() async {
    final token = await PreferencesOTI.getToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Token tidak tersedia.")));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PermissionScreen(token: token)),
    );

    if (result == true) {
      await fetchAbsenStatistics(); // Refresh statistik absen setelah izin
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Statistik absen diperbarui setelah pengajuan izin"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildBody(),
                Positioned(
                  top: -40,
                  left: 16,
                  right: 16,
                  child: _buildAttendanceCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child:
                        (user?.profilePhotoUrl != null &&
                                user!.profilePhotoUrl!.isNotEmpty)
                            ? Image.network(
                              user!.profilePhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                            )
                            : const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.grey,
                            ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Semangat Pagi",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      user?.name ?? 'Memuat nama...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      selectedTraining.isNotEmpty
                          ? selectedTraining
                          : "Memuat...",
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColor.purpleMain,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildLocationAndTime(),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Statistik Absen",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColor.purpleMain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildAbsenStatsCard(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final formattedTime = DateFormat('HH : mm : ss').format(_now);
    final formattedDay = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_now);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEBFA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 32, color: Colors.black87),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDay,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndTime() {
    final formattedCheckIn =
        checkInTime != null
            ? DateFormat('HH : mm').format(checkInTime!)
            : "-- : --";
    final formattedCheckOut =
        checkOutTime != null
            ? DateFormat('HH : mm').format(checkOutTime!)
            : "-- : --";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: AppColor.purpleMain),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  currentAddress,
                  style: TextStyle(fontSize: 12, color: AppColor.purpleMain),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeBox(
                "Clock In",
                formattedCheckIn,
                onPressed:
                    checkInTime == null
                        ? () async {
                          final result =
                              await Navigator.pushNamed(
                                    context,
                                    CheckinScreen.id,
                                  )
                                  as Map<String, dynamic>?;
                          if (result != null && result['checkInTime'] != null) {
                            setState(() {
                              checkInTime = DateFormat(
                                'HH:mm',
                              ).parse(result['checkInTime']);
                            });
                            getCurrentLocation();
                            fetchAbsenStatistics(); // Refresh stats after check-in
                          }
                        }
                        : null,
              ),
              _buildTimeBox(
                "Clock Out",
                formattedCheckOut,
                onPressed:
                    (checkInTime != null && checkOutTime == null)
                        ? () async {
                          final result =
                              await Navigator.pushNamed(
                                    context,
                                    CheckOutScreen.id,
                                  )
                                  as Map<String, dynamic>?;
                          if (result != null &&
                              result['checkOutTime'] != null) {
                            setState(() {
                              checkOutTime = DateFormat(
                                'HH:mm',
                              ).parse(result['checkOutTime']);
                            });
                            getCurrentLocation();
                            fetchAbsenStatistics(); // Refresh stats after check-out
                          }
                        }
                        : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: ajukanIzin,
              icon: const Icon(Icons.edit_calendar, color: Colors.white),
              label: const Text("Ajukan Izin"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purpleMain,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String label, String time, {VoidCallback? onPressed}) {
    return Expanded(
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
            if (onPressed != null)
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.purpleMain,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // New: Widget to display attendance statistics
  Widget _buildAbsenStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          isLoadingStats
              ? const Center(child: CircularProgressIndicator())
              : absenStats == null
              ? const Text("Gagal memuat statistik absen.")
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(
                    "Total Absen:",
                    absenStats!.totalAbsen.toString(),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    "Total Masuk:",
                    absenStats!.totalMasuk.toString(),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    "Total Izin:",
                    absenStats!.totalIzin.toString(),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    "Sudah Absen Hari Ini:",
                    absenStats!.sudahAbsenHariIni ? "Sudah" : "Belum",
                    color:
                        absenStats!.sudahAbsenHariIni
                            ? Colors.green
                            : Colors.red,
                  ),
                ],
              ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: color ?? AppColor.purpleMain),
        ),
      ],
    );
  }
}
