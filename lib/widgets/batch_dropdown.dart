import 'package:flutter/material.dart';
import 'package:ppkd_flutter/models/bathes_model.dart';

class BatchDropdown extends StatelessWidget {
  final List<BatchesData> batchOptions;
  final int? selectedValue;
  final Function(int?) onChanged;

  const BatchDropdown({
    super.key,
    required this.batchOptions,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedValue,
      items:
          batchOptions.map((batch) {
            return DropdownMenuItem<int>(
              value: batch.id,
              child: Text(batch.batchKe, style: TextStyle(fontSize: 14)),
            );
          }).toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Pilih Batch',
        prefixIcon: Icon(Icons.list_alt, size: 20),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }
}
