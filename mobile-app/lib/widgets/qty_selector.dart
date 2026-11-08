import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';

/// محدد كمية موحد — يُستخدم في الكتالوج والسلة.
/// يدعم وضعين: مضغوط (compact) للكتالوج وعادي للسلة.
class QtySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool compact;
  final bool editable;

  const QtySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.compact = false,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: compact ? AppColors.background : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(compact ? 12 : 20),
        border: compact ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onTap: () => onChanged(quantity - 1),
            isPrimary: false,
          ),
          if (editable)
            SizedBox(
              width: 40,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: compact ? 14 : 13,
                  fontWeight: FontWeight.w900,
                ),
                controller: TextEditingController(text: quantity.toString()),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  final newQty = int.tryParse(val) ?? 0;
                  if (newQty != quantity) {
                    onChanged(newQty);
                  }
                },
              ),
            )
          else
            SizedBox(
              width: 30,
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 14 : 13,
                ),
              ),
            ),
          _buildButton(
            icon: Icons.add,
            onTap: () => onChanged(quantity + 1),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    if (compact) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Icon(
            icon,
            size: 18,
            color: isPrimary ? AppColors.primary : AppColors.textLight,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: isPrimary ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }
}
