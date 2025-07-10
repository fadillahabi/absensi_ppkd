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
    return DropdownButtonFormField<int>(
      value: selectedValue,
      items:
          trainingOptions.map((training) {
            return DropdownMenuItem<int>(
              value: training.id,
              child: Text(training.title),
            );
          }).toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Pilih Training',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }
}
