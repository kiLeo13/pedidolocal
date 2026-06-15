import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: const Color(0xFF9C7A50),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Stack(
          children: [
            Positioned(
              right: 18,
              top: 20,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.white.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Icons.local_cafe,
                  size: 48,
                  color: AppConstants.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.warning,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Promo',
                      style: TextStyle(
                        color: AppConstants.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descontos de\nate 50%',
                    style: TextStyle(
                      color: AppConstants.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
