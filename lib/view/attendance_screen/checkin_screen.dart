import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ppkd_flutter/services/attendant_services.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});
  static const String id = "/checkin_screen";

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  GoogleMapController? mapController;
  final LatLng _ppkdCenter = LatLng(-6.2932351, 106.8906202);
  String currentAddress = "Memuat alamat...";
  double? currentDistance;
  bool isInRange = false;
  LatLng? _currentLatLng;
  StreamSubscription<Position>? positionStream;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    listenToLocationChanges();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  void listenToLocationChanges() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((Position position) async {
      final latLng = LatLng(position.latitude, position.longitude);
      final distance = Geolocator.distanceBetween(
        latLng.latitude,
        latLng.longitude,
        _ppkdCenter.latitude,
        _ppkdCenter.longitude,
      );

      setState(() {
        _currentLatLng = latLng;
        currentDistance = distance;
        isInRange = distance <= 100.0;
      });

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      }

      try {
        final placemarks = await placemarkFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          setState(() {
            currentAddress =
                "${p.street}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}";
          });
        }
      } catch (e) {
        print("Gagal mendapatkan alamat: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  child: GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _ppkdCenter,
                      zoom: 17,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: {
                      Marker(
                        markerId: const MarkerId('ppkd'),
                        position: _ppkdCenter,
                        infoWindow: const InfoWindow(
                          title: 'Titik Absen PPKD Jakarta Pusat',
                          snippet: 'Radius 100 meter',
                        ),
                      ),
                      if (_currentLatLng != null)
                        Marker(
                          markerId: const MarkerId('current'),
                          position: _currentLatLng!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ),
                          infoWindow: const InfoWindow(title: "Lokasi Saya"),
                        ),
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId('radius'),
                        center: _ppkdCenter,
                        radius: 100,
                        fillColor: Colors.blue.withOpacity(0.1),
                        strokeColor: Colors.blueAccent,
                        strokeWidth: 2,
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
                    'Jarak dari PPKD Jakarta Pusat',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentDistance != null
                        ? "${currentDistance!.toStringAsFixed(2)} meter"
                        : "Mengukur jarak...",
                    style: const TextStyle(
                      color: Color(0xFF5A32DC),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentAddress,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed:
                    isInRange && !_isLoading
                        ? () async {
                          if (_currentLatLng == null) return;

                          setState(() {
                            _isLoading = true;
                          });

                          final lat = _currentLatLng!.latitude;
                          final lng = _currentLatLng!.longitude;

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

                          setState(() {
                            _isLoading = false;
                          });

                          if (response != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.message),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );

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
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        : null,
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
                  minimumSize: const Size(double.infinity, 0),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                        : const Text("Clock In"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
