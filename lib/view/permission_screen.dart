import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:ppkd_flutter/models/izin_response_model.dart';
import 'package:ppkd_flutter/services/absen_services.dart'; // Adjust path as needed

class PermissionScreen extends StatefulWidget {
  final String token; // Assuming token is passed to this screen

  const PermissionScreen({super.key, required this.token});
  static const String id = "/permission_screen";

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false;

  DateTime? _selectedDate; // To store the selected date internally

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple, // Header background color
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Selected day color
              onPrimary: Colors.white, // Text color of selected day
              onSurface: Colors.black, // Text color for non-selected days
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ), // Dialog background
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitIzin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final IzinResponse response = await AbsenServices.submitIzin(
          token: widget.token,
          date: _dateController.text,
          alasanIzin: _reasonController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Kirim kembali ke HomeScreen dengan data berhasil
        Navigator.pop(
          context,
          true,
        ); // ✅ ini kunci agar HomeScreen tahu perlu refresh
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Izin', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white), // For back button
      ),
      body: Container(
        color: Colors.white, // White background for the body
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Picker
                TextFormField(
                  controller: _dateController,
                  readOnly:
                      true, // Make it read-only so users can only pick a date
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Tanggal Izin',
                    hintText: 'Pilih tanggal izin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2.0,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.deepPurple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal izin tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Reason for Permission
                TextFormField(
                  controller: _reasonController,
                  maxLines: 5, // Allow multi-line input
                  decoration: InputDecoration(
                    labelText: 'Alasan Izin',
                    hintText: 'Cth: Sakit, Urusan Keluarga, dll.',
                    alignLabelWithHint:
                        true, // Aligns label to the top for multi-line
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alasan izin tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitIzin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple, // Button background color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5, // Shadow
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : const Text(
                            'Kirim Pengajuan Izin',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 16),
                  child: Text(
                    '© 2025 Fadillah Abi Prayogo. All Rights Reserved.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
