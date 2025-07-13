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
    double width = MediaQuery.of(context).size.width;

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
        const SizedBox(height: 10),
        Row(
          children: [
            _buildGenderTile(context, 'L', 'Laki-laki', Icons.male),
            const SizedBox(width: 12),
            _buildGenderTile(context, 'P', 'Perempuan', Icons.female),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderTile(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedGender == value;
    final theme = Theme.of(context);
    final textColor = isSelected ? Colors.white : Colors.black87;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.purpleMain : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.purpleMain : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
