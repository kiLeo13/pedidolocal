import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/formatters.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/models/cart_item.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:pedidolocal/providers/cart_provider.dart';
import 'package:pedidolocal/providers/order_provider.dart';
import 'package:pedidolocal/widgets/quantity_selector.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController(text: 'Pedido Local');
  final _addressController = TextEditingController();
  String _paymentMethod = 'pix';
  bool _didPrefill = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrefill) {
      return;
    }
    final profile = context.read<AuthProvider>().currentUser?.profile;
    if (profile != null) {
      _cityController.text = profile.city;
      _addressController.text = profile.addressLine;
      _didPrefill = true;
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pedido')),
      body: cart.isEmpty
          ? const _EmptyCart()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                children: [
                  ...cart.items.map(
                    (item) => _CartLineTile(item: item, cart: cart),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  _CheckoutSummary(subtotal: cart.subtotal),
                  const SizedBox(height: AppConstants.spacingLg),
                  Text(
                    'Entrega',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Endereco de entrega',
                    ),
                    validator: (value) {
                      if ((value?.trim() ?? '').length < 5) {
                        return 'Informe o endereco de entrega.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                    validator: (value) {
                      if ((value?.trim() ?? '').length < 2) {
                        return 'Informe a cidade.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Forma de pagamento',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pix', child: Text('Pix')),
                      DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                      DropdownMenuItem(
                        value: 'card_machine',
                        child: Text('Maquina de cartao'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentMethod = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.isAuthenticated) {
                        return const SizedBox.shrink();
                      }
                      return const _AuthNotice();
                    },
                  ),
                  if (orderProvider.error case final error?) ...[
                    const SizedBox(height: AppConstants.spacingMd),
                    Text(
                      error,
                      style: const TextStyle(color: AppConstants.danger),
                    ),
                  ],
                  const SizedBox(height: 96),
                ],
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: ElevatedButton(
                  onPressed: orderProvider.isLoading ? null : _submit,
                  child: orderProvider.isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Pedir ${AppFormatters.currency(cart.subtotal)}'),
                ),
              ),
            ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      final loggedIn = await Navigator.of(context).pushNamed(Routes.login);
      if (!mounted || loggedIn != true) {
        return;
      }
    }

    if (!mounted) {
      return;
    }
    final cart = context.read<CartProvider>();
    final order = await context.read<OrderProvider>().createOrder(
      items: cart.items,
      paymentMethod: _paymentMethod,
      deliveryCity: _cityController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
    );
    if (!mounted || order == null) {
      return;
    }
    cart.clear();
    Navigator.of(
      context,
    ).pushReplacementNamed(Routes.orderTracking, arguments: order);
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: AppConstants.mutedInk,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Seu carrinho esta vazio.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Adicione produtos do catalogo para montar seu pedido.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.home),
              child: const Text('Ver catalogo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.item, required this.cart});

  final CartItem item;
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppConstants.mutedGreen,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppConstants.darkGreen,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.formattedLineTotal,
                    style: const TextStyle(
                      color: AppConstants.darkGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            QuantitySelector(
              quantity: item.quantity,
              onIncrement: () => cart.increment(item.product),
              onDecrement: () => cart.decrement(item.product),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    const deliveryTax = 0.0;
    final total = subtotal + deliveryTax;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do pedido',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SummaryRow(
              label: 'Produtos',
              value: AppFormatters.currency(subtotal),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            _SummaryRow(
              label: 'Taxa de entrega',
              value: AppFormatters.currency(deliveryTax),
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Total',
              value: AppFormatters.currency(total),
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppConstants.darkGreen,
            fontWeight: FontWeight.w900,
          )
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _AuthNotice extends StatelessWidget {
  const _AuthNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppConstants.mutedGreen,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppConstants.darkGreen),
          SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              'Voce sera direcionado para entrar antes de finalizar.',
              style: TextStyle(
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
