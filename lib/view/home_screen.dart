import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/models/absen_history_model.dart';
import 'package:ppkd_flutter/models/login_model.dart';
import 'package:ppkd_flutter/services/absen_services.dart';
import 'package:ppkd_flutter/services/auth_services.dart';
import 'package:ppkd_flutter/view/attendance_screen/chechkout_screen.dart';
import 'package:ppkd_flutter/view/attendance_screen/checkin_screen.dart';

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
  List<HistoryAbsenData> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    _startClock();
    getCurrentLocation();
    fetchAttendanceHistory();
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

  Future<void> _handleRefresh() async {
    await fetchUserProfile();
    await getCurrentLocation();
    await fetchAttendanceHistory();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil diperbarui")));
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

  Future<void> fetchAttendanceHistory() async {
    final token = await PreferencesOTI.getToken();
    if (token == null) return;

    try {
      final history = await AbsenServices.fetchAbsenHistory(token);
      setState(() {
        attendanceHistory = history;
      });
    } catch (e) {
      print("Gagal mengambil data riwayat absen: $e");
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

    final TextEditingController alasanController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajukan Izin"),
          content: TextField(
            controller: alasanController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Masukkan alasan izin...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final alasan = alasanController.text.trim();
                if (alasan.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Alasan tidak boleh kosong.")),
                  );
                  return;
                }

                try {
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

                  final response = await AbsenServices.submitIzin(
                    token: token,
                    date: today,
                    alasanIzin: alasan,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(response.message)));
                  }

                  await fetchAttendanceHistory();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal mengajukan izin: $e")),
                    );
                  }
                }
              },
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            (user?.profilePhotoUrl != null &&
                                    user!.profilePhotoUrl!.isNotEmpty)
                                ? Image.network(
                                  user!.profilePhotoUrl!,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.grey,
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
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppColor.purpleMain,
                    backgroundColor: Colors.white,
                    displacement: 30,
                    edgeOffset: 10,
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
                          ...attendanceHistory.map((item) {
                            String date = item.attendanceDate.day
                                .toString()
                                .padLeft(2, '0');
                            String month = DateFormat(
                              'MMMM',
                            ).format(item.attendanceDate);
                            String checkIn = item.checkInTime ?? "-- : -- : --";
                            String checkOut =
                                item.checkOutTime ?? "-- : -- : --";
                            return _buildHistoryCard(
                              date,
                              month,
                              checkIn,
                              checkOut,
                            );
                          }),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
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

  Widget _buildAttendanceCard() {
    final formattedTime = DateFormat('HH : mm : ss').format(_now);
    final formattedDay = DateFormat('EEEE, dd MMMM yyyy').format(_now);

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
            ? DateFormat('HH : mm : ss').format(checkInTime!)
            : "-- : -- : --";
    final formattedCheckOut =
        checkOutTime != null
            ? DateFormat('HH : mm : ss').format(checkOutTime!)
            : "-- : -- : --";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
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
                            try {
                              checkOutTime = DateFormat(
                                'HH:mm:ss',
                              ).parse(result['checkOutTime']);
                            } catch (e) {
                              print("Gagal parsing checkOutTime: $e");
                            }
                            getCurrentLocation();
                            setState(() {});
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
