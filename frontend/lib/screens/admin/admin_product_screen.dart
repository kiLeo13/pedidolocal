import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:pedidolocal/providers/catalog_provider.dart';
import 'package:provider/provider.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final _productFormKey = GlobalKey<FormState>();
  final _categoryFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _categoryNameController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();

  bool _didRequestCatalog = false;
  int? _selectedCategoryId;
  bool _isActive = true;
  bool _isAlcoholic = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRequestCatalog) {
      return;
    }
    _didRequestCatalog = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CatalogProvider>().loadCatalog();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final catalog = context.watch<CatalogProvider>();

    if (!auth.isAdmin) {
      return const _AdminOnlyScreen();
    }

    final categories = catalog.categories;
    final selectedCategoryId =
        categories.any((category) => category.id == _selectedCategoryId)
        ? _selectedCategoryId
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo produto')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          _SectionHeader(
            icon: Icons.category_outlined,
            title: 'Categoria',
            subtitle: categories.isEmpty
                ? 'Crie uma categoria antes de cadastrar produtos.'
                : 'Selecione uma categoria existente ou crie outra.',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Form(
            key: _categoryFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _categoryNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome da categoria',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  validator: (value) => _required(value, min: 2),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                TextFormField(
                  controller: _categoryDescriptionController,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Descricao da categoria',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                OutlinedButton.icon(
                  onPressed: catalog.isLoading ? null : _createCategory,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Criar categoria'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          _SectionHeader(
            icon: Icons.local_cafe_outlined,
            title: 'Produto',
            subtitle: 'Produtos ativos aparecem no catalogo dos clientes.',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Form(
            key: _productFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,
                  items: categories
                      .map(
                        (category) => DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: categories.isEmpty || catalog.isLoading
                      ? null
                      : (value) => setState(() => _selectedCategoryId = value),
                  decoration: const InputDecoration(
                    labelText: 'Categoria do produto',
                    prefixIcon: Icon(Icons.list_alt_outlined),
                  ),
                  validator: (value) =>
                      value == null ? 'Selecione uma categoria.' : null,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome do produto',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (value) => _required(value, min: 2),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Descricao',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Preco',
                          prefixIcon: Icon(Icons.attach_money_outlined),
                        ),
                        validator: _priceValidator,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Estoque',
                          prefixIcon: Icon(Icons.numbers_outlined),
                        ),
                        validator: _stockValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Produto ativo'),
                  secondary: const Icon(Icons.visibility_outlined),
                  value: _isActive,
                  onChanged: catalog.isLoading
                      ? null
                      : (value) => setState(() => _isActive = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Produto alcoolico'),
                  secondary: const Icon(Icons.no_drinks_outlined),
                  value: _isAlcoholic,
                  onChanged: catalog.isLoading
                      ? null
                      : (value) => setState(() => _isAlcoholic = value),
                ),
                if (catalog.error case final error?) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    error,
                    style: const TextStyle(color: AppConstants.danger),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingLg),
                ElevatedButton.icon(
                  onPressed: catalog.isLoading || categories.isEmpty
                      ? null
                      : _createProduct,
                  icon: catalog.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Salvar produto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createCategory() async {
    if (!_categoryFormKey.currentState!.validate()) {
      return;
    }
    final catalog = context.read<CatalogProvider>();
    final category = await catalog.createCategory(
      name: _categoryNameController.text.trim(),
      description: _optionalText(_categoryDescriptionController.text),
    );
    if (!mounted || category == null) {
      return;
    }
    setState(() => _selectedCategoryId = category.id);
    _categoryNameController.clear();
    _categoryDescriptionController.clear();
    _showMessage('Categoria criada.');
  }

  Future<void> _createProduct() async {
    if (!_productFormKey.currentState!.validate()) {
      return;
    }
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      return;
    }
    final catalog = context.read<CatalogProvider>();
    final product = await catalog.createProduct(
      categoryId: categoryId,
      name: _nameController.text.trim(),
      description: _optionalText(_descriptionController.text),
      price: _normalizedPrice(),
      stock: int.parse(_stockController.text.trim()),
      isActive: _isActive,
      isAlcoholic: _isAlcoholic,
    );
    if (!mounted || product == null) {
      return;
    }
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.text = '0';
    setState(() {
      _isActive = true;
      _isAlcoholic = false;
    });
    _showMessage('Produto criado.');
  }

  String? _required(String? value, {required int min}) {
    final text = value?.trim() ?? '';
    if (text.length < min) {
      return 'Preencha este campo.';
    }
    return null;
  }

  String? _priceValidator(String? value) {
    final price = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (price == null || price < 0) {
      return 'Informe um preco valido.';
    }
    return null;
  }

  String? _stockValidator(String? value) {
    final stock = int.tryParse((value ?? '').trim());
    if (stock == null || stock < 0) {
      return 'Informe o estoque.';
    }
    return null;
  }

  String _normalizedPrice() {
    final price = double.parse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    return price.toStringAsFixed(2);
  }

  String? _optionalText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppConstants.darkGreen),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppConstants.mutedInk),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminOnlyScreen extends StatelessWidget {
  const _AdminOnlyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo produto')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacingMd),
          child: Text('Apenas administradores podem cadastrar produtos.'),
        ),
      ),
    );
  }
}
