import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/formatters.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/providers/cart_provider.dart';
import 'package:pedidolocal/widgets/quantity_selector.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final hasStock = product.stock > 0 && product.isActive;
    final maxQuantity = product.stock.clamp(1, 99);
    final description = product.description?.trim().isNotEmpty == true
        ? product.description!.trim()
        : 'Este produto ainda nao tem descricao detalhada cadastrada.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
        children: [
          _ProductHero(product: product),
          const SizedBox(height: AppConstants.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              _AvailabilityPill(hasStock: hasStock),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            children: const [
              Icon(Icons.star_rounded, color: AppConstants.warning, size: 20),
              SizedBox(width: 4),
              Text(
                '4.8',
                style: TextStyle(
                  color: AppConstants.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4),
              Text('(230)', style: TextStyle(color: AppConstants.mutedInk)),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text('Descricao', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.mutedInk,
              height: 1.35,
            ),
          ),
          if (product.isAlcoholic) ...[
            const SizedBox(height: AppConstants.spacingMd),
            const _NoticeRow(
              icon: Icons.no_drinks_rounded,
              text: 'Produto alcoolico. Venda permitida apenas para maiores.',
            ),
          ],
          const SizedBox(height: AppConstants.spacingLg),
          Text('Quantidade', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            children: [
              QuantitySelector(
                quantity: _quantity,
                onDecrement: _quantity > 1
                    ? () => setState(() => _quantity -= 1)
                    : null,
                onIncrement: hasStock && _quantity < maxQuantity
                    ? () => setState(() => _quantity += 1)
                    : null,
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Text(
                  hasStock
                      ? '${product.stock} unidade(s) disponiveis'
                      : 'Produto indisponivel no momento',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: AppConstants.white,
            border: Border(top: BorderSide(color: AppConstants.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: AppConstants.mutedInk,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      AppFormatters.currency(product.price * _quantity),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppConstants.darkGreen,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 176,
                child: ElevatedButton(
                  onPressed: hasStock ? _addToCart : null,
                  child: Text(hasStock ? 'Adicionar' : 'Indisponivel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    context.read<CartProvider>().addQuantity(product, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_quantity item(ns) adicionados ao carrinho.')),
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.productImageHeight,
      decoration: BoxDecoration(
        color: AppConstants.ink,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1D1D1D),
                    AppConstants.darkGreen.withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -20,
            bottom: -28,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                color: AppConstants.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.white,
                border: Border.all(color: AppConstants.primaryGreen, width: 4),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                size: 58,
                color: AppConstants.darkGreen,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: const Text(
                'Local',
                style: TextStyle(
                  color: AppConstants.darkGreen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Text(
                product.formattedPrice,
                style: const TextStyle(
                  color: AppConstants.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.hasStock});

  final bool hasStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasStock ? AppConstants.mutedGreen : AppConstants.line,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Text(
        hasStock ? 'Em estoque' : 'Esgotado',
        style: TextStyle(
          color: hasStock ? AppConstants.darkGreen : AppConstants.mutedInk,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppConstants.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.warning),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppConstants.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
