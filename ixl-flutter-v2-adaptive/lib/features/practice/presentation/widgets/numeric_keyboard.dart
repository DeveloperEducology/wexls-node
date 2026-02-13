
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class NumericKeyboard extends StatelessWidget {
  final Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  const NumericKeyboard({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 8),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 8),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 8),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits.map((d) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildButton(
              label: d,
              onTap: () => onDigit(d),
              color: Colors.white,
              textColor: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Backspace
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildButton(
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
              color: Colors.grey.shade300,
              textColor: AppColors.textPrimary,
            ),
          ),
        ),
        // 0
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildButton(
              label: '0',
              onTap: () => onDigit('0'),
              color: Colors.white,
              textColor: AppColors.textPrimary,
            ),
          ),
        ),
        // Submit / Done
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildButton(
              icon: Icons.check,
              onTap: onSubmit,
              color: AppColors.primaryGreen,
              textColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: label != null
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Fredoka', // Kid-friendly font if available from previous context
                  ),
                )
              : Icon(icon, color: textColor, size: 28),
        ),
      ),
    );
  }
}
