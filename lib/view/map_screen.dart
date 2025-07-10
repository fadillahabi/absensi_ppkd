import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ppkd_flutter/sevices/attendant_api.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  static const String id = "/map_screen";

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(3.5952, 98.6722); // Medan
  final double distanceFromPlace = 250.43;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Area
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  child: GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    markers: {
                      Marker(
                        markerId: const MarkerId('my_location'),
                        position: _center,
                      ),
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5A32DC),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Distance Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance from place',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${distanceFromPlace.toStringAsFixed(2)}m',
                    style: const TextStyle(
                      color: Color(0xFF5A32DC),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Jl. Pangeran Diponegoro No 5, Kec. Medan Petisah, Kota Medan, Sumatra Utara',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Attendance Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris header
                  Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Monday",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Check In",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Check Out",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Baris data
                  Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "13-Jun-25",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "07 : 50 : 00",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A32DC),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "-",
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Baris status
                  Row(
                    children: const [
                      Text("Status: ", style: TextStyle(fontSize: 14)),
                      Flexible(
                        child: Text(
                          "Belum Check In",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Button Ambil Foto
            // Tombol Ambil Foto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF5A32DC),
                  size: 22,
                ),
                label: const Text(
                  "Ambil Foto",
                  style: TextStyle(
                    color: Color(0xFF5A32DC),
                    // fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF5A32DC), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(double.infinity, 0), // Full width
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tombol Clock In
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    LocationPermission permission =
                        await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied ||
                        permission == LocationPermission.deniedForever) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied ||
                          permission == LocationPermission.deniedForever) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Izin lokasi ditolak")),
                        );
                        return;
                      }
                    }

                    final position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );

                    final double lat = position.latitude;
                    final double lng = position.longitude;

                    String address = "$lat, $lng";
                    try {
                      final placemarks = await placemarkFromCoordinates(
                        lat,
                        lng,
                      );
                      if (placemarks.isNotEmpty) {
                        final p = placemarks.first;
                        address =
                            "${p.street}, ${p.locality}, ${p.administrativeArea}";
                      }
                    } catch (e) {
                      print("Gagal mendapatkan alamat: $e");
                    }

                    final response = await checkIn(
                      latitude: lat,
                      longitude: lng,
                      address: address,
                    );

                    if (response != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(response.message)));

                      // Kembalikan ke HomeScreen dan bawa waktu check-in
                      Navigator.pop(context, {
                        'checkInTime': response.data.checkInTime,
                        'status': response.data.status,
                        'date': response.data.attendanceDate,
                        'address': response.data.checkInAddress,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Gagal melakukan check in"),
                        ),
                      );
                    }
                  } catch (e) {
                    print("Error saat check-in: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Terjadi kesalahan saat check in"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A32DC),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  minimumSize: const Size(double.infinity, 0), // Full width
                ),
                child: const Text("Clock In"),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
