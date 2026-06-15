import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/models/order.dart';
import 'package:pedidolocal/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      provider.setSelectedOrder(widget.order);
      provider.selectOrder(widget.order.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.selectedOrder ?? widget.order;
    final canCancel = order.status != 'delivered' && order.status != 'canceled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota de entrega'),
        actions: [
          IconButton(
            onPressed: provider.isLoading
                ? null
                : () => provider.selectOrder(order.id),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _LocalMapPreview(),
          const SizedBox(height: AppConstants.spacingLg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _headlineFor(order),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Entrega realizada por Pedido Local',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  _StatusTimeline(status: order.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${order.id}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(order.statusLabel),
                  const SizedBox(height: 4),
                  Text(order.deliveryAddress),
                  const Divider(height: 24),
                  Text('Pagamento: ${order.paymentMethodLabel}'),
                  Text('Status do pagamento: ${order.paymentStatusLabel}'),
                  Text('Total: ${order.formattedSubtotal}'),
                  const SizedBox(height: AppConstants.spacingSm),
                  ...order.items.map(
                    (item) => Text(
                      '${item.quantity}x ${item.productNameSnapshot}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.error case final error?) ...[
            const SizedBox(height: AppConstants.spacingMd),
            Text(error, style: const TextStyle(color: AppConstants.danger)),
          ],
          const SizedBox(height: AppConstants.spacingLg),
          OutlinedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () => provider.selectOrder(order.id),
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar pedido'),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          OutlinedButton.icon(
            onPressed: canCancel && !provider.isLoading
                ? provider.cancelSelectedOrder
                : null,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar pedido'),
          ),
        ],
      ),
    );
  }

  String _headlineFor(Order order) {
    return switch (order.status) {
      'pending' => 'Pedido recebido',
      'confirmed' => 'Pedido confirmado',
      'preparing' => 'Seu pedido esta em preparo',
      'out_for_delivery' => 'Chega em breve',
      'delivered' => 'Pedido entregue',
      'canceled' => 'Pedido cancelado',
      _ => order.statusLabel,
    };
  }
}

class _LocalMapPreview extends StatelessWidget {
  const _LocalMapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          for (final top in const [28.0, 84.0, 142.0, 204.0])
            Positioned(
              top: top,
              left: 0,
              right: 0,
              child: const Divider(
                height: 1,
                thickness: 2,
                color: AppConstants.white,
              ),
            ),
          for (final left in const [38.0, 116.0, 196.0, 268.0])
            Positioned(
              top: 0,
              bottom: 0,
              left: left,
              child: Container(width: 2, color: AppConstants.white),
            ),
          Positioned(
            left: 62,
            top: 174,
            child: _MapPin(
              color: AppConstants.darkGreen,
              icon: Icons.storefront_rounded,
            ),
          ),
          Positioned(
            right: 46,
            top: 74,
            child: _MapPin(
              color: AppConstants.primaryGreen,
              icon: Icons.home_rounded,
            ),
          ),
          Positioned(
            left: 100,
            right: 74,
            top: 96,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                border: Border.all(color: AppConstants.darkGreen, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppConstants.white,
                foregroundColor: AppConstants.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppConstants.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppConstants.ink.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final String status;

  static const _steps = [
    ('pending', 'Recebido', Icons.receipt_long_rounded),
    ('confirmed', 'Confirmado', Icons.verified_rounded),
    ('preparing', 'Preparo', Icons.restaurant_menu_rounded),
    ('out_for_delivery', 'Entrega', Icons.delivery_dining_rounded),
    ('delivered', 'Entregue', Icons.check_circle_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'canceled') {
      return const _CanceledTimeline();
    }

    final currentIndex = _steps.indexWhere((step) => step.$1 == status);
    final activeIndex = currentIndex == -1 ? 0 : currentIndex;

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < _steps.length; index++) ...[
              Expanded(
                child: _TimelineStep(
                  label: _steps[index].$2,
                  icon: _steps[index].$3,
                  isActive: index <= activeIndex,
                  isCurrent: index == activeIndex,
                ),
              ),
              if (index < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    color: index < activeIndex
                        ? AppConstants.primaryGreen
                        : AppConstants.line,
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCurrent,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppConstants.darkGreen : AppConstants.mutedInk;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppConstants.mutedGreen : AppConstants.line,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppConstants.primaryGreen, width: 2)
                : null,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CanceledTimeline extends StatelessWidget {
  const _CanceledTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppConstants.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_rounded, color: AppConstants.danger),
          SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              'Este pedido foi cancelado.',
              style: TextStyle(
                color: AppConstants.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
