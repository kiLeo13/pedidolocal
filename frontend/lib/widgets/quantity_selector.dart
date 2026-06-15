import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';

/// A compact quantity selector with minus and plus controls.
///
/// The minus button is disabled when [quantity] is 1.
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = quantity > 1;

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          _CircleButton(
            icon: Icons.remove,
            onTap: canDecrement ? onDecrement : null,
            enabled: canDecrement,
          ),

          // Quantity display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppConstants.darkText,
              ),
            ),
          ),

          // Plus button
          _CircleButton(icon: Icons.add, onTap: onIncrement, enabled: true),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _CircleButton({required this.icon, this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: enabled ? AppConstants.primaryGreen : AppConstants.dividerColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppConstants.white : AppConstants.secondaryText,
          ),
        ),
      ),
    );
  }
}
