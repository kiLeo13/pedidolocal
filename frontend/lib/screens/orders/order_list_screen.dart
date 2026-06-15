import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/models/order.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:pedidolocal/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<OrderProvider>().loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            onPressed: auth.isAuthenticated && !provider.isLoading
                ? provider.loadOrders
                : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !auth.isAuthenticated
          ? _LoginPrompt(
              onLogin: () async {
                final loggedIn = await Navigator.of(
                  context,
                ).pushNamed(Routes.login);
                if (!context.mounted || loggedIn != true) {
                  return;
                }
                context.read<OrderProvider>().loadOrders();
              },
            )
          : RefreshIndicator(
              onRefresh: provider.loadOrders,
              child: _OrderListBody(provider: provider),
            ),
    );
  }
}

class _OrderListBody extends StatelessWidget {
  const _OrderListBody({required this.provider});

  final OrderProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.orders.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Text(provider.error!, textAlign: TextAlign.center),
            ),
          ),
        ],
      );
    }
    if (provider.orders.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Nenhum pedido encontrado.')),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: provider.orders.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppConstants.spacingSm),
      itemBuilder: (context, index) {
        final order = provider.orders[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            title: Text('Pedido #${order.id}'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _StatusChip(order: order),
                  Text(order.paymentMethodLabel),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.formattedSubtotal,
                  style: const TextStyle(
                    color: AppConstants.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
            onTap: () {
              context.read<OrderProvider>().setSelectedOrder(order);
              Navigator.of(
                context,
              ).pushNamed(Routes.orderTracking, arguments: order);
            },
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isCanceled = order.status == 'canceled';
    final isDelivered = order.status == 'delivered';
    final color = isCanceled
        ? AppConstants.danger
        : isDelivered
        ? AppConstants.darkGreen
        : AppConstants.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Entre para ver seus pedidos.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onLogin, child: const Text('Entrar')),
          ],
        ),
      ),
    );
  }
}
