import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Pedido Local');
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'customer';

  bool get _isCustomer => _role == 'customer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          children: [
            Text(
              'Dados da conta',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'customer',
                  icon: Icon(Icons.person_outline_rounded),
                  label: Text('Cliente'),
                ),
                ButtonSegment(
                  value: 'admin',
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  label: Text('Admin'),
                ),
              ],
              selected: {_role},
              onSelectionChanged: auth.isLoading
                  ? null
                  : (values) => setState(() => _role = values.single),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) => _required(value, min: 2),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty || !text.contains('@')) {
                  return 'Informe um e-mail valido.';
                }
                return null;
              },
            ),
            if (_isCustomer) ...[
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (value) =>
                    _required(value, min: AppConstants.phoneMinLength),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Endereco'),
                validator: (value) => _required(value, min: 5),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _cityController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator: (value) => _required(value, min: 2),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              TextFormField(
                controller: _birthDateController,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Data de nascimento',
                  hintText: 'AAAA-MM-DD',
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Senha'),
              validator: (value) {
                final password = value ?? '';
                if (password.length < AppConstants.passwordMinLength) {
                  return 'Use pelo menos 8 caracteres.';
                }
                if (!RegExp('[a-z]').hasMatch(password) ||
                    !RegExp('[A-Z]').hasMatch(password) ||
                    !RegExp('[0-9]').hasMatch(password)) {
                  return 'Use letras maiusculas, minusculas e numero.';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            if (auth.error case final error?) ...[
              const SizedBox(height: AppConstants.spacingMd),
              Text(error, style: const TextStyle(color: AppConstants.danger)),
            ],
            const SizedBox(height: AppConstants.spacingLg),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar conta'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final auth = context.read<AuthProvider>();
    final birthDate = _birthDateController.text.trim();
    await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      role: _role,
      phone: _isCustomer ? _phoneController.text.trim() : null,
      addressLine: _isCustomer ? _addressController.text.trim() : null,
      city: _isCustomer ? _cityController.text.trim() : null,
      birthDate: _isCustomer && birthDate.isNotEmpty ? birthDate : null,
    );
    if (!mounted || !auth.isAuthenticated) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
  }

  String? _required(String? value, {required int min}) {
    final text = value?.trim() ?? '';
    if (text.length < min) {
      return 'Preencha este campo.';
    }
    return null;
  }
}
