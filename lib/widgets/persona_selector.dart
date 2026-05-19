import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'burnit_palette.dart';

class PersonaSelector extends StatelessWidget {
  const PersonaSelector({
    required this.selectedPersona,
    required this.onSelected,
    super.key,
  });

  final String selectedPersona;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _PersonaChip(
            label: '따뜻한 위로',
            isSelected: selectedPersona == 'warm',
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected('warm');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PersonaChip(
            label: '같이 화내기',
            isSelected: selectedPersona == 'rage',
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected('rage');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PersonaChip(
            label: '현실적 조언',
            isSelected: selectedPersona == 'advice',
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected('advice');
            },
          ),
        ),
      ],
    );
  }
}

class _PersonaChip extends StatelessWidget {
  const _PersonaChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? BurnitPalette.chipSelectedBg : BurnitPalette.chipUnselectedBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? BurnitPalette.chipSelectedFg : BurnitPalette.chipUnselectedFg,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
