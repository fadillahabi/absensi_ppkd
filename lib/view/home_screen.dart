import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ppkd_flutter/constant/app_color.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/models/login_model.dart';
import 'package:ppkd_flutter/models/trainings_model.dart';
import 'package:ppkd_flutter/sevices/auth_services.dart';
import 'package:ppkd_flutter/view/chechkout_screen.dart';
import 'package:ppkd_flutter/view/checkin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = "/home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DataTrainings> trainings = [];
  String selectedTraining = "";
  UserLogin? user;

  DateTime _now = DateTime.now();
  Timer? _timer;

  DateTime? checkInTime;
  DateTime? checkOutTime;

  String currentAddress = "Memuat lokasi...";

  @override
  void initState() {
    super.initState();
    fetchTrainings();
    fetchUserProfile();
    _startClock();
    getCurrentLocation();
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

  Future<void> fetchUserProfile() async {
    final token = await PreferencesOTI.getToken();
    if (token == null) return;

    try {
      final result = await UserApi.getProfile(token);
      setState(() {
        user = result;
      });
    } catch (e) {
      print("Gagal mengambil data user: $e");
    }
  }

  Future<void> fetchTrainings() async {
    try {
      final response = await UserApi.getTrainings();
      setState(() {
        trainings = response;
        if (trainings.isNotEmpty) {
          selectedTraining = trainings[0].title;
        }
      });
    } catch (e) {
      print("Gagal mengambil data training: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child:
                          (user?.profilePhotoUrl != null)
                              ? Image.network(
                                user!.profilePhotoUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 24,
                                      color: Colors.grey,
                                    ),
                              )
                              : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
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
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAttendanceCard(),
                      const SizedBox(height: 20),
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
                        "11",
                        "Thursday",
                        "08 : 10 : 00",
                        "17 : 05 : 00",
                      ),
                      _buildHistoryCard(
                        "10",
                        "Wednesday",
                        "08 : 00 : 00",
                        "17 : 00 : 00",
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final formattedTime = DateFormat('HH : mm : ss').format(_now);
    final formattedDay = DateFormat('EEEE, dd MMMM yyyy').format(_now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
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
    );
  }

  Widget _buildLocationAndTime() {
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
                "Check In",
                checkInTime != null
                    ? DateFormat('HH : mm : ss').format(checkInTime!)
                    : "-- : -- : --",
                showButton: true,
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, CheckinScreen.id)
                          as Map<String, dynamic>?;

                  if (result != null && result['checkInTime'] != null) {
                    setState(() {
                      checkInTime = DateFormat(
                        'HH:mm',
                      ).parse(result['checkInTime']);
                    });
                    getCurrentLocation();
                  }
                },
              ),
              _buildTimeBox(
                "Check Out",
                checkOutTime != null
                    ? DateFormat('HH : mm : ss').format(checkOutTime!)
                    : "-- : -- : --",
                showButton: true,
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, CheckOutScreen.id)
                          as Map<String, dynamic>?;

                  if (result != null && result['checkOutTime'] != null) {
                    setState(() {
                      checkOutTime = DateFormat(
                        'HH:mm',
                      ).parse(result['checkOutTime']);
                    });
                    getCurrentLocation();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(
    String label,
    String time, {
    bool showButton = false,
    VoidCallback? onPressed,
  }) {
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
