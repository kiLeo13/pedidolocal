import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/providers/cart_provider.dart';
import 'package:pedidolocal/providers/catalog_provider.dart';
import 'package:pedidolocal/widgets/bottom_nav_bar.dart';
import 'package:pedidolocal/widgets/category_chip.dart';
import 'package:pedidolocal/widgets/loading_shimmer.dart';
import 'package:pedidolocal/widgets/product_card.dart';
import 'package:pedidolocal/widgets/promo_banner.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      if (!catalog.hasLoaded && !catalog.isLoading) {
        catalog.loadCatalog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartProvider, int>(
      (cart) => cart.itemCount,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<CatalogProvider>().loadCatalog(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: PromoBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Consumer<CatalogProvider>(
                  builder: (context, catalog, _) {
                    return CategoryChipSelector(
                      categories: catalog.categories,
                      selectedCategoryId: catalog.selectedCategoryId,
                      onSelected: catalog.selectCategory,
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        'Populares',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        'Catalogo local',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              Consumer<CatalogProvider>(
                builder: (context, catalog, _) {
                  if (catalog.isLoading && !catalog.hasLoaded) {
                    return const SliverToBoxAdapter(
                      child: ProductGridShimmer(),
                    );
                  }
                  if (catalog.error != null && !catalog.hasLoaded) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MessageState(
                        icon: Icons.wifi_off,
                        title: 'Nao foi possivel carregar o catalogo.',
                        message: catalog.error!,
                        actionLabel: 'Tentar novamente',
                        onAction: catalog.loadCatalog,
                      ),
                    );
                  }
                  final products = catalog.visibleProducts;
                  if (products.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MessageState(
                        icon: Icons.search_off,
                        title: 'Nenhum produto encontrado.',
                        message: 'Tente outra busca ou categoria.',
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final categoryName = catalog.categoryNameFor(
                          product.categoryId,
                        );
                        return ProductCard(
                          product: product,
                          categoryName: categoryName,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(Routes.productDetail, arguments: product),
                          onAddTap: product.stock > 0
                              ? () {
                                  context.read<CartProvider>().add(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Produto adicionado.'),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        cartItemCount: cartCount,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed(Routes.orders);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(Routes.cart);
          } else if (index == 3) {
            Navigator.of(context).pushNamed(Routes.profile);
          }
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Localizacao',
            style: TextStyle(
              color: AppConstants.ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Text(
                'Maranhao, Brazil',
                style: TextStyle(
                  color: AppConstants.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: context.read<CatalogProvider>().updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFF2E2E2E),
                    hintStyle: const TextStyle(color: Color(0xFFC8C8C8)),
                    prefixIconColor: const Color(0xFFC8C8C8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: () => context.read<CatalogProvider>().loadCatalog(),
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2E2E),
                  foregroundColor: AppConstants.white,
                  fixedSize: const Size(52, 52),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppConstants.mutedInk),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
