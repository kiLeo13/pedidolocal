import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.categoryName,
    this.onTap,
    this.onAddTap,
  });

  final Product product;
  final String? categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  IconData _iconForCategory(String? name) {
    final lower = name?.toLowerCase() ?? '';
    if (lower.contains('bebida') || lower.contains('suco')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('cafe') || lower.contains('coffee')) {
      return Icons.coffee_rounded;
    }
    if (lower.contains('pizza')) {
      return Icons.local_pizza_rounded;
    }
    if (lower.contains('doce') || lower.contains('sobremesa')) {
      return Icons.cake_rounded;
    }
    return Icons.restaurant_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Ink(
        decoration: BoxDecoration(
          color: AppConstants.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: AppConstants.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppConstants.mutedGreen,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusMedium),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _iconForCategory(categoryName),
                        size: 48,
                        color: AppConstants.darkGreen,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppConstants.warning,
                          ),
                          SizedBox(width: 2),
                          Text(
                            '4.8',
                            style: TextStyle(
                              color: AppConstants.ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppConstants.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    if (categoryName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        categoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppConstants.mutedInk,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.formattedPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppConstants.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: onAddTap,
                          icon: const Icon(Icons.add, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: AppConstants.darkGreen,
                            foregroundColor: AppConstants.white,
                            fixedSize: const Size(32, 32),
                            minimumSize: const Size(32, 32),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
