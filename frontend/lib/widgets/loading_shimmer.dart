import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShimmerCard();
  }
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (context, _) => const ProductCardShimmer(),
    );
  }
}

class DetailShimmer extends StatelessWidget {
  const DetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(height: AppConstants.productImageHeight),
          SizedBox(height: 20),
          _ShimmerBlock(width: 120, height: 18),
          SizedBox(height: 12),
          _ShimmerBlock(height: 22),
          SizedBox(height: 8),
          _ShimmerBlock(width: 180, height: 14),
          SizedBox(height: 24),
          _ShimmerBlock(height: 14),
          SizedBox(height: 8),
          _ShimmerBlock(height: 14),
          SizedBox(height: 8),
          _ShimmerBlock(width: 220, height: 14),
          SizedBox(height: 32),
          _ShimmerBlock(height: 52),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _ShimmerBlock()),
        SizedBox(height: 8),
        _ShimmerBlock(height: 16),
        SizedBox(height: 8),
        _ShimmerBlock(width: 100, height: 14),
        Spacer(),
        _ShimmerBlock(width: 80, height: 20),
      ],
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppConstants.line,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
    );
  }
}
