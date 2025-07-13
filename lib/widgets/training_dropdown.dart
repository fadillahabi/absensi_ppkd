import 'package:flutter/material.dart';
import 'package:ppkd_flutter/models/trainings_model.dart';

class TrainingDropdown extends StatelessWidget {
  final List<DataTrainings> trainingOptions;
  final int? selectedValue;
  final Function(int?) onChanged;

  const TrainingDropdown({
    super.key,
    required this.trainingOptions,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelectedValueValid =
        selectedValue != null &&
        trainingOptions.any((t) => t.id == selectedValue);

    return DropdownButtonFormField<int>(
      isExpanded: true, // ⬅️ penting untuk menghindari overflow
      value: isSelectedValueValid ? selectedValue : null,
      items:
          trainingOptions.map((training) {
            return DropdownMenuItem<int>(
              value: training.id,
              child: Text(
                training.title,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Pilih Training',
        prefixIcon: const Icon(Icons.school, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
      validator:
          (value) => value == null ? 'Pilih training terlebih dahulu' : null,
    );
  }
}
