import 'package:flutter/material.dart';
import 'package:ppkd_flutter/helper/shared_preference.dart';
import 'package:ppkd_flutter/models/login_model.dart'; // Model user
import 'package:ppkd_flutter/services/auth_services.dart';
import 'package:ppkd_flutter/view/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String id = "/profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserLogin> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserProfile();
  }

  Future<UserLogin> fetchUserProfile() async {
    print("Memuat ulang profil...");
    final token = await PreferencesOTI.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Pengguna belum login.');
    }
    return UserApi.getProfile(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserLogin>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final user = snapshot.data!;

          return Column(
            children: [
              // Header Profile
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 42),
                padding: const EdgeInsets.only(top: 100, bottom: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF5A32DC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(99),
                    bottomRight: Radius.circular(99),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            (user.profilePhotoUrl != null &&
                                    user.profilePhotoUrl!.isNotEmpty)
                                ? Image.network(
                                  "${user.profilePhotoUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
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
                                : const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name ?? 'Nama tidak tersedia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? 'Email tidak tersedia',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu Items
              _buildMenuItem(
                icon: Icons.person_outline,
                text: "Ubah Profil",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );

                  if (result != null && result is UserLogin) {
                    print("Profil diperbarui, pakai data terbaru...");
                    setState(() {
                      _userFuture = Future.value(
                        result,
                      ); // ← langsung pakai hasil terbaru
                    });
                  }
                },
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                text: "Ubah Kata Sandi",
                iconColor: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, "/change_password_screen");
                },
              ),
              _buildMenuItem(
                icon: Icons.logout,
                text: "Keluar",
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  PreferencesOTI.clearSession(); // Hapus token
                  Navigator.pushReplacementNamed(context, "/login_screen");
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(text, style: TextStyle(color: textColor)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
