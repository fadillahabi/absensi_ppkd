import 'package:flutter/material.dart';
import 'package:ppkd_flutter/constant/app_color.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jenis Kelamin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _genderTile('L', 'Laki-laki')),
            const SizedBox(width: 12),
            Expanded(child: _genderTile('P', 'Perempuan')),
          ],
        ),
      ],
    );
  }

  Widget _genderTile(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              selectedGender == value
                  ? AppColor.purpleMain
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedGender,
        title: Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
        onChanged: onChanged,
      ),
    );
  }
}
