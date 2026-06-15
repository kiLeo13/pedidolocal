import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/models/category.dart';

/// A horizontal scrollable list of category chips.
///
/// The first chip is always "Todos" (all categories). When [selectedCategoryId]
/// is `null`, "Todos" is visually selected. Tapping a chip calls [onSelected]
/// with the category id (or `null` for "Todos").
class CategoryChipSelector extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  const CategoryChipSelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        itemCount: categories.length + 1, // +1 for "Todos"
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Chip(
              label: 'Todos',
              isSelected: selectedCategoryId == null,
              onTap: () => onSelected(null),
            );
          }

          final category = categories[index - 1];
          return _Chip(
            label: category.name,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryGreen : AppConstants.white,
          borderRadius: BorderRadius.circular(AppConstants.chipRadius),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryGreen
                : AppConstants.dividerColor,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppConstants.white : AppConstants.darkText,
            ),
          ),
        ),
      ),
    );
  }
}
